import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  static const String spriteBaseUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/';

  // Cache for already fetched Pokemon
  static final Map<String, Pokemon> _cache = {};
  // Cache for evolution chains to avoid duplicate requests
  static final Map<String, List<Evolution>> _evolutionCache = {};
  // Cache for species data
  static final Map<String, Map<String, dynamic>> _speciesCache = {};

  // Persistent client for all requests
  static final http.Client _persistentClient = http.Client();

  /// Fetches a list of all Pokémon from the API with optimized loading
  static Future<List<Pokemon>> fetchPokemonList({int limit = 1025}) async {
    final response = await _persistentClient.get(Uri.parse('$baseUrl?limit=$limit'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'];

      // Process Pokemon in optimal-sized batches for maximum throughput
      const int batchSize = 30; // Optimal batch size for parallelism without overwhelming the API
      List<Pokemon> pokemonList = [];

      for (int i = 0; i < results.length; i += batchSize) {
        final end = (i + batchSize < results.length) ? i + batchSize : results.length;
        final batch = results.sublist(i, end);

        final batchResults = await Future.wait(
            batch.map((pokemon) => fetchPokemonDetails(pokemon['url']))
        );

        pokemonList.addAll(batchResults);

        // Optional: Add a loading progress callback here if you want to show progress
        // if (onProgress != null) {
        //   onProgress((i + batchSize) / results.length);
        // }
      }

      return pokemonList;
    } else {
      throw Exception('Failed to load Pokémon list: ${response.statusCode}');
    }
  }

  /// Fetches detailed information about a single Pokémon
  static Future<Pokemon> fetchPokemonDetails(String url, {http.Client? client}) async {
    // Return cached Pokemon if available
    if (_cache.containsKey(url)) {
      return _cache[url]!;
    }

    final httpClient = client ?? _persistentClient;

    try {
      // Fetch basic Pokemon data
      final response = await httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load Pokémon details: ${response.statusCode}');
      }
      final jsonData = json.decode(response.body);

      // Extract species URL
      final speciesUrl = jsonData['species']['url'];

      // Fetch species data and evolution chain concurrently to speed up loading
      final speciesDataFuture = _fetchSpeciesData(speciesUrl, httpClient);

      // Wait for species data first since we need it for evolution chain URL
      final speciesData = await speciesDataFuture;
      final evolutionUrl = speciesData['evolution_chain']['url'];

      // Now fetch evolution chain
      final evolutionChainFuture = _fetchEvolutionChain(evolutionUrl, httpClient);

      // Extract English description while waiting for evolution chain
      String description = _extractEnglishDescription(speciesData);

      // Wait for evolution chain data
      final evolutionChain = await evolutionChainFuture;

      // Create and cache Pokemon object
      final pokemon = Pokemon.fromJson(jsonData, description, evolutionChain);
      _cache[url] = pokemon;

      return pokemon;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches species data with caching
  static Future<Map<String, dynamic>> _fetchSpeciesData(String url, http.Client httpClient) async {
    // Return cached species data if available
    if (_speciesCache.containsKey(url)) {
      return _speciesCache[url]!;
    }

    final response = await httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon species: ${response.statusCode}');
    }

    final speciesData = json.decode(response.body);
    _speciesCache[url] = speciesData;
    return speciesData;
  }

  /// Extracts English description from species data
  static String _extractEnglishDescription(Map<String, dynamic> speciesData) {
    try {
      // Faster lookup by directly searching for English entries
      for (var entry in speciesData['flavor_text_entries']) {
        if (entry['language']['name'] == 'en') {
          return entry['flavor_text']
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ');
        }
      }
      return 'No description available.';
    } catch (e) {
      return 'No description available.';
    }
  }

  /// Fetches the evolution chain with caching
  static Future<List<Evolution>> _fetchEvolutionChain(String url, http.Client httpClient) async {
    // Return cached evolution chain if available
    if (_evolutionCache.containsKey(url)) {
      return _evolutionCache[url]!;
    }

    try {
      final response = await httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Evolution> evolutionList = [];

        // Process the entire chain
        _processEvolutionChain(data['chain'], evolutionList);

        _evolutionCache[url] = evolutionList;
        return evolutionList;
      } else {
        throw Exception('Failed to load evolution chain: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Recursively processes evolution chain to handle multiple evolve paths
  static void _processEvolutionChain(Map<String, dynamic> chain, List<Evolution> evolutionList) {
    if (chain == null) return;

    String name = chain['species']['name'];
    int id = getPokemonIdFromUrl(chain['species']['url']);
    String imageUrl = '$spriteBaseUrl$id.png';

    evolutionList.add(Evolution(name: name, imageUrl: imageUrl));

    // Process all possible evolution paths (not just the first one)
    if (chain['evolves_to'] != null && chain['evolves_to'].isNotEmpty) {
      for (var evolution in chain['evolves_to']) {
        _processEvolutionChain(evolution, evolutionList);
      }
    }
  }

  /// Extracts Pokémon ID from the species URL
  static int getPokemonIdFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.pathSegments[uri.pathSegments.length - 2]);
  }

  /// Pre-fetch commonly used Pokémon to improve initial loading experience
  static Future<void> preloadCommonPokemon() async {
    // List of popular Pokémon IDs to preload
    final List<int> popularIds = [1, 4, 7, 25, 150, 151]; // Bulbasaur, Charmander, Squirtle, Pikachu, Mewtwo, Mew

    await Future.wait(
        popularIds.map((id) => fetchPokemonDetails('$baseUrl/$id'))
    );
  }

  /// Dispose of resources when the app is closed
  static void dispose() {
    _persistentClient.close();
    _cache.clear();
    _evolutionCache.clear();
    _speciesCache.clear();
  }
}

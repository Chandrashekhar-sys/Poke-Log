import 'package:dio/dio.dart';
import '../models/pokemon.dart';

class ApiService {
  final Dio _dio = Dio();

  /// Fetches a list of Pokémon with optimized parallel requests
  Future<List<Pokemon>> fetchPokemonList(int limit, int offset) async {
    List<Pokemon> pokemonList = [];

    try {
      // Prepare all requests in parallel
      List<Future<Response>> pokemonRequests = [];
      List<Future<Response>> speciesRequests = [];

      for (int i = offset + 1; i <= offset + limit; i++) {
        pokemonRequests.add(_dio.get('https://pokeapi.co/api/v2/pokemon/$i'));
        speciesRequests.add(_dio.get('https://pokeapi.co/api/v2/pokemon-species/$i'));
      }

      // Execute all API requests in parallel
      final pokemonResponses = await Future.wait(pokemonRequests);
      final speciesResponses = await Future.wait(speciesRequests);

      for (int i = 0; i < pokemonResponses.length; i++) {
        final pokemonResponse = pokemonResponses[i];
        final speciesResponse = speciesResponses[i];

        if (pokemonResponse.statusCode == 200 && speciesResponse.statusCode == 200) {
          final evolutionUrl = speciesResponse.data['evolution_chain']['url'];

          // Extract safe English description
          final description = _extractEnglishDescription(speciesResponse.data);

          // Fetch evolution chain
          final evolutionChain = await fetchEvolutionChain(evolutionUrl);

          // Create Pokémon object
          pokemonList.add(Pokemon.fromJson(pokemonResponse.data, description, evolutionChain));
        }
      }
    } catch (e) {
      print('Error fetching Pokémon: $e');
    }

    return pokemonList;
  }

  /// Fetches evolution chain recursively
  Future<List<Evolution>> fetchEvolutionChain(String url) async {
    List<Evolution> evolutionChain = [];
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        _processEvolutionChain(response.data['chain'], evolutionChain);
      }
    } catch (e) {
      print('Error fetching evolution chain: $e');
    }
    return evolutionChain;
  }

  /// Recursively processes the evolution chain
  void _processEvolutionChain(Map<String, dynamic> chain, List<Evolution> evolutionList) {
    if (chain == null) return;

    final name = chain['species']['name'];
    final id = _extractIdFromUrl(chain['species']['url']);
    final imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png";

    evolutionList.add(Evolution(name: name, imageUrl: imageUrl));

    for (var evolution in chain['evolves_to']) {
      _processEvolutionChain(evolution, evolutionList);
    }
  }

  /// Extracts English description from species data safely
  String _extractEnglishDescription(Map<String, dynamic> speciesData) {
    try {
      for (var entry in speciesData['flavor_text_entries']) {
        if (entry['language']['name'] == 'en') {
          return entry['flavor_text'].replaceAll('\n', ' ').replaceAll('\f', ' ');
        }
      }
    } catch (e) {
      print('Error extracting description: $e');
    }
    return 'No description available.';
  }

  /// Extracts Pokémon ID from species URL
  int _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.pathSegments[uri.pathSegments.length - 2]);
  }
}

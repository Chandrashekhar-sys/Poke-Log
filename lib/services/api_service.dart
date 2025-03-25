import 'package:dio/dio.dart';
import '../models/pokemon.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Pokemon>> fetchPokemonList(int limit, int offset) async {
    List<Pokemon> pokemonList = [];

    try {
      for (int i = offset + 1; i <= offset + limit; i++) {
        final pokemonResponse = await _dio.get('https://pokeapi.co/api/v2/pokemon/$i');
        final speciesResponse = await _dio.get('https://pokeapi.co/api/v2/pokemon-species/$i');

        if (pokemonResponse.statusCode == 200 && speciesResponse.statusCode == 200) {
          final evolutionUrl = speciesResponse.data['evolution_chain']['url'];
          final description = speciesResponse.data['flavor_text_entries'][0]['flavor_text'];

          // Fetch evolution chain
          final evolutionChain = await fetchEvolutionChain(evolutionUrl);

          // Create the Pokémon object
          pokemonList.add(Pokemon.fromJson(pokemonResponse.data, description, evolutionChain));
        }
      }
    } catch (e) {
      print('Error fetching Pokémon: $e');
    }

    return pokemonList;
  }

  Future<List<Evolution>> fetchEvolutionChain(String url) async {
    List<Evolution> evolutionChain = [];
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        var chain = response.data['chain'];

        while (chain != null) {
          final name = chain['species']['name'];
          final id = _extractIdFromUrl(chain['species']['url']);
          final imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png";

          evolutionChain.add(Evolution(name: name, imageUrl: imageUrl));

          if (chain['evolves_to'].isNotEmpty) {
            chain = chain['evolves_to'][0];
          } else {
            chain = null;
          }
        }
      }
    } catch (e) {
      print('Error fetching evolution chain: $e');
    }

    return evolutionChain;
  }

  int _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.pathSegments[uri.pathSegments.length - 2]);
  }
}

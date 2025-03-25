import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

Future<void> loadPokemonData(context) async {
  final String response = await rootBundle.loadString('assets/pokemon.json');
  final List<dynamic> data = json.decode(response);

  final List<Pokemon> pokemonList = data.map<Pokemon>((json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
      types: List<String>.from(json['types'].map((t) => t['type']['name'].toString().toUpperCase())),
      description: json['flavor_text_entries'] != null
          ? json['flavor_text_entries'][0]['flavor_text']
          : 'No description available.',
      height: json['height'] / 10.0, // Convert decimeters to meters
      weight: json['weight'] / 10.0, // Convert hectograms to kilograms
      abilities: List<String>.from(json['abilities'].map((a) => a['ability']['name'])),
      stats: {
        for (var s in json['stats'])
          s['stat']['name']: s['base_stat'] as int,
      },
      evolutionChain: (json['evolutionChain'] as List<dynamic>?)
          ?.map<Evolution>((e) => Evolution(
        name: e['name'],
        imageUrl: e['imageUrl'],
      ))
          .toList() ??
          [],
    );
  }).toList();

  context.read<PokemonProvider>().loadPokemonData(pokemonList);
}

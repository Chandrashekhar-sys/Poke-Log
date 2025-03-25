import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: pokemon.imageUrl,
            height: 100,
            width: 100,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Text(
            pokemon.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

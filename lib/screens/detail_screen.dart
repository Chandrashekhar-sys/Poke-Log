import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class DetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    // Get type color for theming
    final Color primaryTypeColor = _getTypeColor(pokemon.types.first);
    final Color backgroundColor = primaryTypeColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(pokemon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryTypeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with curved bottom and image
            Container(
              color: primaryTypeColor,
              child: Column(
                children: [
                  // Pokémon ID
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                      child: Text(
                        "#${pokemon.id.toString().padLeft(3, '0')}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),

                  // Pokémon Image with shadow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow/glow effect
                      Container(
                        width: 160,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(80),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),

                      // Pokemon image
                      Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: Image.network(
                          pokemon.imageUrl,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Curved container for the content
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pokemon Name
                  Center(
                    child: Text(
                      pokemon.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Types with styled chips
                  Center(
                    child: Wrap(
                      spacing: 12.0,
                      children: pokemon.types.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getTypeColor(type).withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Height & Weight with icons
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoColumn(Icons.straighten, "Height", "${pokemon.height}m"),
                          const VerticalDivider(thickness: 1),
                          _buildInfoColumn(Icons.fitness_center, "Weight", "${pokemon.weight}kg"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pokemon.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Abilities
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Abilities",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pokemon.abilities.map((ability) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatAbilityName(ability),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats section with improved bars
                  const Text(
                    "Base Stats",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats bars
                  _buildStatsSection(pokemon, context),

                  const SizedBox(height: 24),

                  // Evolution Chain with improved styling
                  const Text(
                    "Evolution Chain",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildEvolutionChain(pokemon),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for info columns
  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blueGrey),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Stats section builder
  Widget _buildStatsSection(Pokemon pokemon, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: pokemon.stats.entries.map((entry) {
            // Get max value for normalization (typically 255 for base stats)
            final double maxValue = 255;
            final double normalizedValue = entry.value / maxValue;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Stat name
                  SizedBox(
                    width: 120,
                    child: Text(
                      _formatStatName(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                  // Stat value
                  SizedBox(
                    width: 40,
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Progress bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            height: 10,
                            color: Colors.grey.shade200,
                          ),
                          // Foreground
                          Container(
                            height: 10,
                            width: MediaQuery.of(context).size.width * 0.5 * normalizedValue,
                            decoration: BoxDecoration(
                              color: _getStatColor(entry.key),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatColor(entry.key).withOpacity(0.5),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Evolution chain builder
  Widget _buildEvolutionChain(Pokemon pokemon) {
    if (pokemon.evolutionChain.isEmpty) {
      return const Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "This Pokémon does not evolve",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pokemon.evolutionChain.asMap().entries.map((entry) {
              final int index = entry.key;
              final evo = entry.value;

              // Check if this evolution is the current Pokémon
              final bool isCurrentPokemon = evo.name.toLowerCase() == pokemon.name.toLowerCase();

              return Row(
                children: [
                  // Evolution pokemon
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrentPokemon
                              ? _getTypeColor(pokemon.types.first).withOpacity(0.3)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(70),
                        ),
                        child: Image.network(
                          evo.imageUrl,
                          height: 80,
                          width: 80,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _capitalizeFirstLetter(evo.name),
                        style: TextStyle(
                          fontWeight: isCurrentPokemon
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  // Arrow between pokemon (except for the last one)
                  if (index < pokemon.evolutionChain.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _getTypeColor(pokemon.types.first),
                        size: 24,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Helper method to capitalize first letter
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  // Format ability name to be more readable
  String _formatAbilityName(String ability) {
    return ability.split('-')
        .map((word) => _capitalizeFirstLetter(word))
        .join(' ');
  }

  // Function to format stat names
  String _formatStatName(String stat) {
    switch (stat.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'speed':
        return 'Speed';
      case 'special-attack':
        return 'Sp. Attack';
      case 'special-defense':
        return 'Sp. Defense';
      default:
        return stat.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  // Function to set stat bar colors based on stat type
  Color _getStatColor(String stat) {
    switch (stat.toLowerCase()) {
      case 'hp':
        return Colors.green.shade400;
      case 'attack':
        return Colors.red.shade400;
      case 'defense':
        return Colors.brown.shade400;
      case 'speed':
        return Colors.blue.shade400;
      case 'special-attack':
        return Colors.orange.shade400;
      case 'special-defense':
        return Colors.teal.shade400;
      default:
        return Colors.grey;
    }
  }

  // Function to set color based on Pokémon type
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return Colors.grey.shade400;
      case 'fire':
        return Colors.orange.shade700;
      case 'water':
        return Colors.blue.shade600;
      case 'electric':
        return Colors.amber.shade600;
      case 'grass':
        return Colors.green.shade600;
      case 'ice':
        return Colors.cyan.shade400;
      case 'fighting':
        return Colors.red.shade800;
      case 'poison':
        return Colors.purple.shade700;
      case 'ground':
        return Colors.brown.shade500;
      case 'flying':
        return Colors.indigo.shade300;
      case 'psychic':
        return Colors.pink.shade400;
      case 'bug':
        return Colors.lightGreen.shade700;
      case 'rock':
        return Colors.brown.shade400;
      case 'ghost':
        return Colors.indigo.shade600;
      case 'dragon':
        return Colors.indigo.shade800;
      case 'dark':
        return Colors.grey.shade800;
      case 'steel':
        return Colors.blueGrey.shade400;
      case 'fairy':
        return Colors.pink.shade300;
      default:
        return Colors.grey;
    }
  }
}
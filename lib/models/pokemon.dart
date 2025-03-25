class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final String description;
  final double height;
  final double weight;
  final List<String> abilities;
  final Map<String, int> stats;
  final List<Evolution> evolutionChain;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.description,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.evolutionChain,
  });

  /// Factory constructor to parse JSON
  factory Pokemon.fromJson(Map<String, dynamic> json, String description, List<Evolution> evolutionChain) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'].toString().toUpperCase())
          .toList(),
      description: description.isNotEmpty ? description : 'No description available.',
      height: json['height'] / 10.0, // Convert decimeters to meters
      weight: json['weight'] / 10.0, // Convert hectograms to kilograms
      abilities: (json['abilities'] as List)
          .map((a) => a['ability']['name'].toString())
          .toList(),
      stats: {
        for (var s in json['stats'])
          s['stat']['name']: s['base_stat'] as int,
      },
      evolutionChain: evolutionChain,
    );
  }
}

class Evolution {
  final String name;
  final String imageUrl;

  Evolution({required this.name, required this.imageUrl});

  factory Evolution.fromJson(Map<String, dynamic> json) {
    return Evolution(
      name: json['species']['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
    );
  }
}

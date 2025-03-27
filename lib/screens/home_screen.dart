import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showTitle = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 50 && !_showTitle) {
      setState(() {
        _showTitle = true;
      });
    } else if (_scrollController.offset <= 50 && _showTitle) {
      setState(() {
        _showTitle = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pokemonProvider = Provider.of<PokemonProvider>(context);
    final pokemonList = pokemonProvider.pokemonList;

    // Filter Pokémon based on search query
    final filteredPokemon = pokemonList.where((pokemon) {
      if (_searchQuery.isEmpty) return true;
      return pokemon.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pokemon.id.toString().contains(_searchQuery);
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with search functionality
          SliverAppBar(
            pinned: true,
            expandedHeight: 160.0,
            backgroundColor: Colors.red.shade700,
            leading: _isSearching
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _toggleSearch,
            )
                : null,
        flexibleSpace: FlexibleSpaceBar(
          title: _isSearching
              ? null
              : (_showTitle
              ? const Text(
            'PokéLog',
            style: TextStyle(color: Colors.white),
          )
              : null),
        background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.shade600,
                          Colors.red.shade800,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pokeball icon
                          Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(height: 8),
                          // PokéLog text
                          Text(
                            "PokéLog",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 3.0,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your Pokémon companion",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  // Pokeball pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: LayoutBuilder(
                          builder: (context, constraints) {
                            return CustomPaint(
                              painter: PokeBallPatternPainter(),
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                            );
                          }
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  _showFilterDialog(context);
                },
              ),
            ],
          ),

          // Search bar (shown only when searching)
          if (_isSearching)
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                color: Colors.red.shade700,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(color: Colors.grey.shade800),
                      decoration: InputDecoration(
                        hintText: 'Search by name or ID...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search, color: Colors.red.shade700),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade600),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

          // Search results count when searching
          if (_isSearching && _searchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Found ${filteredPokemon.length} Pokémon',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Pokémon ListView
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index >= filteredPokemon.length) return null;

                  final pokemon = filteredPokemon[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildPokemonListItem(context, pokemon),
                  );
                },
                childCount: filteredPokemon.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.arrow_upward),
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildPokemonListItem(BuildContext context, Pokemon pokemon) {
    final primaryTypeColor = _getTypeColor(pokemon.types.first);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetailScreen(pokemon: pokemon),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      child: Hero(
        tag: 'pokemon-${pokemon.id}',
        child: Card(
          elevation: 6,
          shadowColor: primaryTypeColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  primaryTypeColor,
                  primaryTypeColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Pokéball background
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.network(
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),

                // Content
                Row(
                  children: [
                    // Pokemon Image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          topRight: Radius.circular(60),
                          bottomRight: Radius.circular(60),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Pokemon Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Name and ID
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _capitalizeFirstLetter(pokemon.name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "#${pokemon.id.toString().padLeft(3, '0')}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Types
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: pokemon.types.map((type) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    type,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Arrow indicator
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter Pokémon",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "By Type:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Normal',
                    'Fire',
                    'Water',
                    'Electric',
                    'Grass',
                    'Ice',
                    'Fighting',
                    'Poison',
                    'Ground',
                    'Flying',
                    'Psychic',
                    'Bug',
                    'Rock',
                    'Ghost',
                    'Dragon',
                    'Dark',
                    'Steel',
                    'Fairy'
                  ].map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: false,
                        onSelected: (selected) {
                          // Implementation
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: type == 'All' ? Colors.grey : _getTypeColor(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Sort by ID
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.sort_by_alpha),
                    label: const Text("Sort by ID"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Sort by Name
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.sort_by_alpha),
                    label: const Text("Sort by Name"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

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

// Custom painter for Pokeball pattern background
class PokeBallPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw multiple small pokeballs as a pattern
    final pokeballRadius = size.width / 20;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 4; j++) {
        final centerX = i * size.width / 4 - pokeballRadius / 2;
        final centerY = j * size.height / 2 - pokeballRadius / 2;

        // Draw outer circle
        canvas.drawCircle(
          Offset(centerX, centerY),
          pokeballRadius,
          paint,
        );

        // Draw horizontal line
        canvas.drawLine(
          Offset(centerX - pokeballRadius, centerY),
          Offset(centerX + pokeballRadius, centerY),
          paint,
        );

        // Draw small center circle
        canvas.drawCircle(
          Offset(centerX, centerY),
          pokeballRadius / 3,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
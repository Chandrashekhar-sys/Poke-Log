import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class PokemonProvider with ChangeNotifier {
  List<Pokemon> _pokemonList = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // Getters
  List<Pokemon> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // Lazy loading initialization
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      // Defer loading to next frame to prevent UI blocking during app startup
      await Future.delayed(Duration.zero);
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load data with chunking for better performance
  Future<void> loadPokemonData(List<Pokemon> data) async {
    if (_isLoading) return;

    try {
      _setLoading(true);

      // Clear any previous data
      _pokemonList = [];

      // Process data in chunks to avoid blocking the UI thread
      const chunkSize = 20;

      for (int i = 0; i < data.length; i += chunkSize) {
        await Future.microtask(() {
          final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
          final chunk = data.sublist(i, end);
          _pokemonList.addAll(chunk);
          // Notify after each chunk to show progress
          notifyListeners();
        });

        // Allow UI to update between chunks
        await Future.delayed(const Duration(milliseconds: 10));
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get Pokemon by ID with caching for better performance
  final Map<int, Pokemon> _pokemonCache = {};

  Pokemon? getPokemonById(int id) {
    // Check cache first for faster lookup
    if (_pokemonCache.containsKey(id)) {
      return _pokemonCache[id];
    }

    try {
      final pokemon = _pokemonList.firstWhere((pokemon) => pokemon.id == id);
      // Cache the result for future lookups
      _pokemonCache[id] = pokemon;
      return pokemon;
    } catch (e) {
      return null;
    }
  }

  // Add a single Pokemon efficiently
  void addPokemon(Pokemon pokemon) {
    if (!_pokemonList.any((p) => p.id == pokemon.id)) {
      _pokemonList.add(pokemon);
      _pokemonCache[pokemon.id] = pokemon;
      notifyListeners();
    }
  }

  // Clear data and cache
  void clearData() {
    _pokemonList = [];
    _pokemonCache.clear();
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pokemon_provider.dart';
import 'screens/home_screen.dart';
import 'services/pokemon_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PokemonProvider(),
      child: const PokeApp(),
    );
  }
}

class PokeApp extends StatefulWidget {
  const PokeApp({super.key});

  @override
  _PokeAppState createState() => _PokeAppState();
}

class _PokeAppState extends State<PokeApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    final pokemonList = await PokemonService.fetchPokemonList();
    if (mounted) {
      Provider.of<PokemonProvider>(context, listen: false).loadPokemonData(pokemonList);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeLog',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: isLoading ? const LoadingScreen() : const HomeScreen(),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

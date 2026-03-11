import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/provider/pokemon_provider.dart';
import 'package:pokedex/widgets/pokemon_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonProvider _pokemonProvider = PokemonProvider();
  final Random _random = Random();

  static const int _cardsPerRender = 6;
  static const int _maxPokemonDexNumber = 1025;

  late Future<List<Pokemon>> _pokemonsFuture;

  @override
  void initState() {
    super.initState();
    _loadRandomPokemons();
  }

  List<int> _generateRandomPokedexNumbers() {
    final numbers = <int>{};
    while (numbers.length < _cardsPerRender) {
      numbers.add(_random.nextInt(_maxPokemonDexNumber) + 1);
    }
    return numbers.toList();
  }

  void _loadRandomPokemons() {
    _pokemonsFuture = _pokemonProvider.fetchPokemons(
      _generateRandomPokedexNumbers(),
    );
  }

  Future<void> _refreshRandomPokemons() async {
    setState(_loadRandomPokemons);
    await _pokemonsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pokemon>>(
      future: _pokemonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load Pokemon right now.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final pokemons = snapshot.data ?? [];

        if (pokemons.isEmpty) {
          return const Center(child: Text('No Pokemon found.'));
        }

        return RefreshIndicator(
          onRefresh: _refreshRandomPokemons,
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: pokemons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return PokemonCard(pokemon: pokemons[index]);
            },
          ),
        );
      },
    );
  }
}

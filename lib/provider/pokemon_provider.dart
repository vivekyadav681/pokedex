import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex/models/pokemon.dart';

class PokemonProvider {
  PokemonProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Pokemon> fetchPokemonById(int id) async {
    final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon/$id');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokemon #$id');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Pokemon.fromJson(data);
  }

  Future<List<Pokemon>> fetchPokemons(List<int> pokedexNumbers) async {
    return Future.wait(pokedexNumbers.map(fetchPokemonById));
  }
}

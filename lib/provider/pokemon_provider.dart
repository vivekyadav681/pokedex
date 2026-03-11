import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/models/evolution.dart';
import 'package:pokedex/models/pokemon_species.dart';

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

  Future<PokemonSpecies> fetchPokemonSpecies(String speciesName) async {
    final uri = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon-species/$speciesName',
    );
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load species for $speciesName');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PokemonSpecies.fromJson(data);
  }

  Future<EvolutionChain> fetchEvolutionChain(String speciesName) async {
    final speciesUri = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon-species/$speciesName',
    );
    final speciesResponse = await _client.get(speciesUri);

    if (speciesResponse.statusCode != 200) {
      throw Exception('Failed to load species for $speciesName');
    }

    final speciesData =
        jsonDecode(speciesResponse.body) as Map<String, dynamic>;
    final evolutionChainUrl =
        speciesData['evolution_chain']?['url']?.toString() ?? '';

    if (evolutionChainUrl.isEmpty) {
      throw Exception('No evolution chain found for $speciesName');
    }

    final chainUri = Uri.parse(evolutionChainUrl);
    final chainResponse = await _client.get(chainUri);

    if (chainResponse.statusCode != 200) {
      throw Exception('Failed to load evolution chain for $speciesName');
    }

    final chainData = jsonDecode(chainResponse.body) as Map<String, dynamic>;
    return EvolutionChain.fromJson(chainData);
  }

  Future<Map<String, dynamic>> fetchPokemonsPaginated({
    required int offset,
    required int limit,
  }) async {
    final uri = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit',
    );
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokemon list');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }

  Future<Pokemon> fetchPokemonByName(String name) async {
    final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokemon: $name');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    var pokemon = Pokemon.fromJson(data);

    try {
      final speciesData = await fetchPokemonSpecies(name);
      pokemon = pokemon.copyWith(
        generation: speciesData.generation,
        isLegendary: false,
        isMythical: false,
        isPseudoLegendary: false,
      );

      final speciesJson = await _fetchSpeciesJson(name);
      pokemon = pokemon.copyWith(
        isLegendary: (speciesJson['is_legendary'] as bool?) ?? false,
        isMythical: (speciesJson['is_mythical'] as bool?) ?? false,
      );

      pokemon = _checkPseudoLegendary(pokemon, speciesJson);
    } catch (e) {
      // Continue with default values if species fetch fails
    }

    return pokemon;
  }

  Future<Map<String, dynamic>> _fetchSpeciesJson(String name) async {
    final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$name');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Pokemon _checkPseudoLegendary(
    Pokemon pokemon,
    Map<String, dynamic> speciesJson,
  ) {
    final evolvesFromSpecies = speciesJson['evolves_from_species'];
    final evolutionChainUrl =
        speciesJson['evolution_chain']?['url']?.toString() ?? '';

    final isPseudo =
        pokemon.stats.values.fold(0, (sum, val) => sum + val) >= 600 &&
        !pokemon.isLegendary &&
        !pokemon.isMythical &&
        evolvesFromSpecies != null &&
        evolutionChainUrl.isNotEmpty;

    return isPseudo ? pokemon.copyWith(isPseudoLegendary: true) : pokemon;
  }
}

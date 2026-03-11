class PokemonSpecies {
  PokemonSpecies({
    required this.name,
    required this.eggGroups,
    required this.generation,
  });

  final String name;
  final List<String> eggGroups;
  final String generation;

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    return PokemonSpecies(
      name: json['name']?.toString() ?? '',
      eggGroups: (json['egg_groups'] as List<dynamic>? ?? [])
          .map((entry) {
            final group = entry as Map<String, dynamic>? ?? {};
            return group['name']?.toString() ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toList(),
      generation:
          ((json['generation'] as Map<String, dynamic>? ?? {})['name']
              ?.toString() ??
          ''),
    );
  }
}

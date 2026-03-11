class Pokemon {
  Pokemon({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.imageUrls,
  });

  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final List<String> imageUrls;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = (json['sprites'] as Map<String, dynamic>? ?? {});
    final other = (sprites['other'] as Map<String, dynamic>? ?? {});
    final officialArtwork =
        (other['official-artwork'] as Map<String, dynamic>? ?? {});
    final home = (other['home'] as Map<String, dynamic>? ?? {});

    final images = <String>{
      officialArtwork['front_default']?.toString() ?? '',
      home['front_default']?.toString() ?? '',
      sprites['front_default']?.toString() ?? '',
      sprites['front_shiny']?.toString() ?? '',
    }.where((url) => url.isNotEmpty).toList();

    final parsedStats = <String, int>{};
    final statsJson = (json['stats'] as List<dynamic>? ?? []);
    for (final statEntry in statsJson) {
      final statMap = statEntry as Map<String, dynamic>;
      final stat = statMap['stat'] as Map<String, dynamic>? ?? {};
      final statName = stat['name']?.toString() ?? '';
      if (statName.isEmpty) {
        continue;
      }
      parsedStats[statName] = (statMap['base_stat'] as num?)?.toInt() ?? 0;
    }

    return Pokemon(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      baseExperience: (json['base_experience'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      types: (json['types'] as List<dynamic>? ?? [])
          .map((entry) {
            final type =
                (entry as Map<String, dynamic>)['type']
                    as Map<String, dynamic>? ??
                {};
            return type['name']?.toString() ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toList(),
      abilities: (json['abilities'] as List<dynamic>? ?? [])
          .map((entry) {
            final ability =
                (entry as Map<String, dynamic>)['ability']
                    as Map<String, dynamic>? ??
                {};
            return ability['name']?.toString() ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toList(),
      stats: parsedStats,
      imageUrls: images,
    );
  }
}

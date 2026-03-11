class Evolution {
  Evolution({
    required this.id,
    required this.name,
    required this.evolutionDetails,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String evolutionDetails;
  final String imageUrl;
}

class EvolutionChain {
  EvolutionChain({required this.evolutions});

  final List<Evolution> evolutions;

  factory EvolutionChain.fromJson(Map<String, dynamic> json) {
    final evolutions = <Evolution>[];
    _parseChain(json['chain'] as Map<String, dynamic>? ?? {}, evolutions);
    return EvolutionChain(evolutions: evolutions);
  }

  static void _parseChain(
    Map<String, dynamic> chainData,
    List<Evolution> evolutions,
  ) {
    final species = chainData['species'] as Map<String, dynamic>? ?? {};
    final speciesName = species['name']?.toString() ?? '';
    final speciesUrl = species['url']?.toString() ?? '';

    if (speciesName.isNotEmpty) {
      final id = _extractIdFromUrl(speciesUrl);
      final imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
      final evolvesTo = chainData['evolves_to'] as List<dynamic>? ?? [];

      String details = 'Base form';
      if (evolvesTo.isNotEmpty) {
        final evolutionDetails =
            (evolvesTo.first as Map<String, dynamic>)['evolution_details']
                as List<dynamic>? ??
            [];
        if (evolutionDetails.isNotEmpty) {
          final detailMap =
              evolutionDetails.first as Map<String, dynamic>? ?? {};
          details = _buildEvolutionDetails(detailMap);
        }
      }

      evolutions.add(
        Evolution(
          id: id,
          name: speciesName,
          evolutionDetails: details,
          imageUrl: imageUrl,
        ),
      );

      for (final evolution in evolvesTo) {
        final evoMap = evolution as Map<String, dynamic>? ?? {};
        _parseChain(evoMap, evolutions);
      }
    }
  }

  static int _extractIdFromUrl(String url) {
    final parts = url.split('/');
    return int.tryParse(parts.length > 1 ? parts[parts.length - 2] : '') ?? 0;
  }

  static String _buildEvolutionDetails(Map<String, dynamic> details) {
    final parts = <String>[];

    if (details.containsKey('min_level') && details['min_level'] != null) {
      parts.add('Level ${details['min_level']}');
    }
    if (details.containsKey('item') && details['item'] != null) {
      final item = details['item'] as Map<String, dynamic>;
      final itemName = item['name']?.toString() ?? '';
      if (itemName.isNotEmpty) {
        parts.add('Use $itemName');
      }
    }
    if (details.containsKey('trigger') && details['trigger'] != null) {
      final trigger = details['trigger'] as Map<String, dynamic>;
      final triggerName = trigger['name']?.toString() ?? '';
      if (triggerName.isNotEmpty && triggerName != 'level-up') {
        parts.add(_toTitleCase(triggerName));
      }
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Evolution';
  }

  static String _toTitleCase(String value) {
    return value
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length == 1) {
            return part.toUpperCase();
          }
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }
}

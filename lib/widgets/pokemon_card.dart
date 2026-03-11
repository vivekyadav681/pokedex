import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/screens/pokemon_detail_screen.dart';

class PokemonCard extends StatefulWidget {
  const PokemonCard({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PokemonDetailScreen(pokemon: pokemon),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _toTitleCase(pokemon.name),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('#${pokemon.id}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCarousel(context, pokemon),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...pokemon.types.map(_buildTypeChip),
                  ...pokemon.abilities.map(_buildAbilityChip),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _detailText('Base XP', '${pokemon.baseExperience}'),
                  _detailText('Height', '${pokemon.height / 10} m'),
                  _detailText('Weight', '${pokemon.weight / 10} kg'),
                ],
              ),
              const SizedBox(height: 12),
              _buildStats(pokemon),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, Pokemon pokemon) {
    final images = pokemon.imageUrls;

    if (images.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.image_not_supported_outlined, size: 36),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _activeImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 36),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            final isActive = index == _activeImageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    return Chip(
      label: Text(_toTitleCase(type)),
      backgroundColor: Colors.red.shade50,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAbilityChip(String ability) {
    return Chip(
      label: Text('Ability: ${_toTitleCase(ability)}'),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _detailText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildStats(Pokemon pokemon) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pokemon.stats.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('${_toTitleCase(entry.key)}: ${entry.value}'),
        );
      }).toList(),
    );
  }

  String _toTitleCase(String value) {
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

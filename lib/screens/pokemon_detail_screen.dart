import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/models/evolution.dart';
import 'package:pokedex/models/pokemon_species.dart';
import 'package:pokedex/provider/pokemon_provider.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokemonProvider _provider = PokemonProvider();
  late Future<(EvolutionChain, PokemonSpecies)> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture =
        Future.wait([
          _provider.fetchEvolutionChain(widget.pokemon.name),
          _provider.fetchPokemonSpecies(widget.pokemon.name),
        ]).then(
          (results) =>
              (results[0] as EvolutionChain, results[1] as PokemonSpecies),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_toTitleCase(widget.pokemon.name)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: FutureBuilder<(EvolutionChain, PokemonSpecies)>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load details.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final (evolutionChain, species) =
              snapshot.data ??
              (
                EvolutionChain(evolutions: []),
                PokemonSpecies(name: '', eggGroups: [], generation: ''),
              );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildImageSection(),
              const SizedBox(height: 20),
              _buildBasicInfo(),
              const SizedBox(height: 20),
              _buildSpeciesInfo(species),
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 20),
              _buildAbilitiesSection(),
              const SizedBox(height: 20),
              _buildEvolutionChain(evolutionChain),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(12),
            child: widget.pokemon.imageUrls.isNotEmpty
                ? Image.network(
                    widget.pokemon.imageUrls[0],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.catching_pokemon, size: 48),
                  )
                : const Icon(Icons.image_not_supported_outlined, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            '#${widget.pokemon.id}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Info',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _infoRow('Height', '${widget.pokemon.height / 10} m'),
            _infoRow('Weight', '${widget.pokemon.weight / 10} kg'),
            _infoRow('Base XP', '${widget.pokemon.baseExperience}'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text(
                  'Types: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                ...widget.pokemon.types.map(
                  (type) => Chip(
                    label: Text(_toTitleCase(type)),
                    backgroundColor: Colors.red.shade50,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesInfo(PokemonSpecies species) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Species Info',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _infoRow('Generation', _toTitleCase(species.generation)),
            if (species.eggGroups.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Text(
                    'Egg Groups: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  ...species.eggGroups.map(
                    (group) => Chip(
                      label: Text(_toTitleCase(group)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base Stats',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...widget.pokemon.stats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_toTitleCase(entry.key)),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / 200,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abilities',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.pokemon.abilities
                  .map(
                    (ability) => Chip(
                      label: Text(_toTitleCase(ability)),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolutionChain(EvolutionChain chain) {
    if (chain.evolutions.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolution Chain',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chain.evolutions.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Icon(
                    Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              itemBuilder: (context, index) {
                final evo = chain.evolutions[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Image.network(
                          evo.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _toTitleCase(evo.name),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evo.evolutionDetails,
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(value),
        ],
      ),
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

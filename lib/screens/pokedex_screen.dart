import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/provider/pokemon_provider.dart';
import 'package:pokedex/widgets/pokemon_small_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokemonProvider _provider = PokemonProvider();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Pokemon> _allPokemons;
  late List<Pokemon> _displayedPokemons;
  bool _isLoading = false;
  bool _isSearching = false;
  static const int _totalLimit = 2000; // Load all Pokemon at once

  // Filter states
  Set<int> _selectedGenerations = {};
  bool _filterLegendary = false;
  bool _filterMythical = false;
  bool _filterPseudoLegendary = false;
  Set<String> _selectedTypes = {};

  static const Map<int, String> _generationMap = {
    1: 'Gen I',
    2: 'Gen II',
    3: 'Gen III',
    4: 'Gen IV',
    5: 'Gen V',
    6: 'Gen VI',
    7: 'Gen VII',
    8: 'Gen VIII',
    9: 'Gen IX',
  };

  static const List<String> _allTypes = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  @override
  void initState() {
    super.initState();
    _allPokemons = [];
    _displayedPokemons = [];
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadInitialPokemons();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Scroll listener for future use
    // Pagination disabled - all Pokemon loaded upfront
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  bool _hasActiveFilters() {
    return _selectedGenerations.isNotEmpty ||
        _filterLegendary ||
        _filterMythical ||
        _filterPseudoLegendary ||
        _selectedTypes.isNotEmpty ||
        _searchController.text.trim().isNotEmpty;
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _isSearching = _hasActiveFilters();
      _displayedPokemons = _allPokemons.where((pokemon) {
        // Search filter
        if (query.isNotEmpty) {
          if (!pokemon.name.toLowerCase().contains(query) &&
              !pokemon.id.toString().contains(query)) {
            return false;
          }
        }

        // Generation filter
        if (_selectedGenerations.isNotEmpty) {
          final gen = _getGeneration(pokemon.id);
          if (!_selectedGenerations.contains(gen)) {
            return false;
          }
        }

        // Legendary filter
        if (_filterLegendary && !pokemon.isLegendary) {
          return false;
        }

        // Mythical filter
        if (_filterMythical && !pokemon.isMythical) {
          return false;
        }

        // Pseudo-legendary filter
        if (_filterPseudoLegendary && !pokemon.isPseudoLegendary) {
          return false;
        }

        // Type filter
        if (_selectedTypes.isNotEmpty) {
          final hasType = pokemon.types.any(
            (type) => _selectedTypes.contains(type),
          );
          if (!hasType) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  int _getGeneration(int pokemonId) {
    if (pokemonId <= 151) return 1;
    if (pokemonId <= 251) return 2;
    if (pokemonId <= 386) return 3;
    if (pokemonId <= 493) return 4;
    if (pokemonId <= 649) return 5;
    if (pokemonId <= 721) return 6;
    if (pokemonId <= 807) return 7;
    if (pokemonId <= 898) return 8;
    return 9;
  }

  Future<void> _loadInitialPokemons() async {
    setState(() {
      _isLoading = true;
      _allPokemons = [];
      _displayedPokemons = [];
    });

    try {
      await _fetchAllPokemons();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading Pokemon: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllPokemons() async {
    final data = await _provider.fetchPokemonsPaginated(
      offset: 0,
      limit: _totalLimit,
    );

    final results = (data['results'] as List<dynamic>? ?? []);

    // Batch fetch Pokemon in groups of 50 for better performance
    const batchSize = 50;
    final allPokemons = <Pokemon>[];

    for (int i = 0; i < results.length; i += batchSize) {
      if (!mounted) return;

      final batch = results.sublist(
        i,
        i + batchSize > results.length ? results.length : i + batchSize,
      );

      List<Future<Pokemon>> futures = [];

      for (final result in batch) {
        final resultMap = result as Map<String, dynamic>;
        final name = resultMap['name']?.toString() ?? '';

        if (name.isNotEmpty) {
          futures.add(_provider.fetchPokemonByName(name));
        }
      }

      try {
        final batchPokemons = await Future.wait(futures);
        allPokemons.addAll(batchPokemons);

        if (mounted) {
          setState(() {
            _allPokemons = allPokemons;
            _applyFilters();
          });
        }
      } catch (e) {
        // Continue with next batch even if some fail
      }
    }

    if (!mounted) return;

    setState(() {
      _allPokemons = allPokemons;
      _applyFilters();
    });
  }

  Widget _buildFilterPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Generation filter
            Text(
              'Generation',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _generationMap.entries.map((entry) {
                final isSelected = _selectedGenerations.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenerations.add(entry.key);
                      } else {
                        _selectedGenerations.remove(entry.key);
                      }
                    });
                    _applyFilters();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Status filters
            Text(
              'Status',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Legendary'),
                  selected: _filterLegendary,
                  onSelected: (selected) {
                    setState(() {
                      _filterLegendary = selected;
                    });
                    _applyFilters();
                  },
                ),
                FilterChip(
                  label: const Text('Mythical'),
                  selected: _filterMythical,
                  onSelected: (selected) {
                    setState(() {
                      _filterMythical = selected;
                    });
                    _applyFilters();
                  },
                ),
                FilterChip(
                  label: const Text('Pseudo-Legendary'),
                  selected: _filterPseudoLegendary,
                  onSelected: (selected) {
                    setState(() {
                      _filterPseudoLegendary = selected;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type filter
            Text(
              'Type',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTypes.map((type) {
                final isSelected = _selectedTypes.contains(type);
                return FilterChip(
                  label: Text(_toTitleCase(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTypes.add(type);
                      } else {
                        _selectedTypes.remove(type);
                      }
                    });
                    _applyFilters();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Clear filters button
            if (_hasActiveFilters())
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedGenerations.clear();
                    _filterLegendary = false;
                    _filterMythical = false;
                    _filterPseudoLegendary = false;
                    _selectedTypes.clear();
                    _searchController.clear();
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Pokemon by name or #ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged();
                          },
                          child: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => DraggableScrollableSheet(
                            expand: false,
                            builder: (_, scrollController) =>
                                _buildFilterPanel(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filters'),
                    ),
                  ),
                  if (_hasActiveFilters())
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Badge(label: Text(_getFilterCount().toString())),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _allPokemons.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _displayedPokemons.isEmpty && !_isLoading
              ? Center(
                  child: Text(
                    _isSearching ? 'No Pokemon found' : 'No Pokemon loaded yet',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                )
              : Stack(
                  children: [
                    GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _displayedPokemons.length,
                      itemBuilder: (context, index) {
                        return PokemonSmallCard(
                          pokemon: _displayedPokemons[index],
                        );
                      },
                    ),
                    if (_isLoading)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  int _getFilterCount() {
    return _selectedGenerations.length +
        (_filterLegendary ? 1 : 0) +
        (_filterMythical ? 1 : 0) +
        (_filterPseudoLegendary ? 1 : 0) +
        _selectedTypes.length;
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

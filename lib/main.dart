import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/screens/home_screen.dart';
import 'package:pokedex/screens/pc_screen.dart';
import 'package:pokedex/screens/pokedex_screen.dart';
import 'package:pokedex/screens/team_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TeamScreen(),
    PcScreen(),
    PokedexScreen(),
  ];

  final List<String> _titles = const ['Home', 'Team', 'PC', 'Pokedex'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
        title: Text(_titles[_currentIndex]),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'PC',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_outlined),
            label: 'Pokedex',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PcScreen extends StatelessWidget {
  const PcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'PC',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    );
  }
}

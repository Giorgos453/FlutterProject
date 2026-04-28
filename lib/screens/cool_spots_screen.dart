import 'package:flutter/material.dart';

class CoolSpotsScreen extends StatelessWidget {
  const CoolSpotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cool Spots')),
      body: const Center(
        child: Text('Cool spots — coming soon'),
      ),
    );
  }
}

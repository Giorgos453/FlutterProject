import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 80),
          SizedBox(height: 16),
          Text('Favorites Screen', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

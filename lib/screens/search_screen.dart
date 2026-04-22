import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80),
          SizedBox(height: 16),
          Text('Search Screen', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

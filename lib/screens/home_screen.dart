import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 80),
          SizedBox(height: 16),
          Text('Home Screen', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

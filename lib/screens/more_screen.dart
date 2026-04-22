import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.more_horiz, size: 80),
          SizedBox(height: 16),
          Text('More Screen', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

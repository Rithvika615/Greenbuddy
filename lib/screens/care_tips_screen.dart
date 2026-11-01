
import 'package:flutter/material.dart';

class CareTipsScreen extends StatelessWidget {
  const CareTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Check soil moisture before watering.',
      'Give plants suitable sunlight.',
      'Remove dry and damaged leaves.',
      'Use pots with proper drainage.',
      'Clean leaves gently to remove dust.',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Plant Care Tips 🌿',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ...tips.map(
          (tip) => Card(
            child: ListTile(
              leading: const Icon(Icons.eco, color: Colors.green),
              title: Text(tip),
            ),
          ),
        ),
      ],
    );
  }
}

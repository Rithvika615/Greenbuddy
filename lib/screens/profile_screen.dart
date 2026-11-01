
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFE5F3E7),
            child: Icon(Icons.person, size: 50, color: Colors.green),
          ),
          const SizedBox(height: 15),
          const Text(
            'Plant Lover',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('GreenBuddy User'),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About GreenBuddy'),
            subtitle: const Text('Your personal plant-care companion'),
          ),
        ],
      ),
    );
  }
}

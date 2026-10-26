import 'package:flutter/material.dart';

class StylistProfileScreen extends StatelessWidget {
  const StylistProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: const Center(
        child: Text('Profile Details'),
      ),
    );
  }
}

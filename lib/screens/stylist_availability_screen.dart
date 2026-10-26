import 'package:flutter/material.dart';

class StylistAvailabilityScreen extends StatelessWidget {
  const StylistAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Availability')),
      body: const Center(
        child: Text('Availability Settings'),
      ),
    );
  }
}

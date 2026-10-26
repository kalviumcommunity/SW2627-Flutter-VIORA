import 'package:flutter/material.dart';

class StylistServicesScreen extends StatelessWidget {
  const StylistServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      body: const Center(
        child: Text('Services Provided'),
      ),
    );
  }
}

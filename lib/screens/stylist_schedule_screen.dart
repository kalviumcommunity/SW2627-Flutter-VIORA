import 'package:flutter/material.dart';

class StylistScheduleScreen extends StatelessWidget {
  const StylistScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/stylist_availability'),
          child: const Text('Manage Availability'),
        ),
      ),
    );
  }
}

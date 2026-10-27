import 'package:flutter/material.dart';

class StylistAppointmentDetailsScreen extends StatelessWidget {
  const StylistAppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: const Center(
        child: Text('Appointment Info'),
      ),
    );
  }
}

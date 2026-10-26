import 'package:flutter/material.dart';

class StylistHomeScreen extends StatelessWidget {
  const StylistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stylist Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/stylist_appointment_details'),
              child: const Text('Appointment Details'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/stylist_schedule'),
              child: const Text('My Schedule'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/stylist_services'),
              child: const Text('My Services'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/stylist_profile'),
              child: const Text('My Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

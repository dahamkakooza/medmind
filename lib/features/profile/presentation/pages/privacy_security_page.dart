import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: const Center(
        child: Text(
          'Privacy & Security Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
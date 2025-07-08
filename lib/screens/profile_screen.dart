import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('👤 Profile screen opened');
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(child: Text("User Profile Info")),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:blo_tracker/services/user_db_service.dart';
import 'package:blo_tracker/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserDatabaseService.getUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text("User info not found"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  Text(
                    "Name: ${_user!.name}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Email: ${_user!.email}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Phone: ${_user!.phone}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}

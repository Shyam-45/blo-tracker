import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blo_tracker/services/auth_service.dart';
import 'package:blo_tracker/providers/app_state_provider.dart';
import 'package:blo_tracker/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blo_tracker/services/user_db_service.dart';
import 'package:blo_tracker/models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final result = await AuthService.login(email, password);
      final token = result['token'];
      final user = result['user'];

      // Store token & profile
      final appNotifier = ref.read(appStateProvider.notifier);
      await appNotifier.setLogin(token);

      await UserDatabaseService.insertUser(UserModel.fromJson(user));

      final shouldTrack = shouldEnforceTrackingNow(
        appNotifier.state.userDisabledToday,
      );
      if (shouldTrack) {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always) {
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/permission');
          return;
        }
      }
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  "Welcome to BLO Tracker",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value!.trim(),
                  validator: (value) =>
                      value!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  onSaved: (value) => password = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitLogin,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

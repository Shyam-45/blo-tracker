import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blo_tracker/services/location_service.dart';
import 'package:blo_tracker/providers/app_state_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    Future.microtask(() async {
      if (!appState.isLoggedIn) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);

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
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

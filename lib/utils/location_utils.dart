import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<Position?> fetchCurrentLocation(BuildContext context) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      print('📴 Location services are disabled.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('🚫 Location permission denied.');
      return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    print('📍 Position: $position');
    return position;
  } catch (e) {
    print('❌ Location error: $e');
    return null;
  }
}

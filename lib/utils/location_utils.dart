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

Future<Position?> fetchLocationSilently() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('📴 BG: Location service disabled');
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      print('🚫 BG: Location permission not sufficient');
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    print('📍 BG: $position');
    return position;
  } catch (e) {
    print('❌ BG Location error: $e');
    return null;
  }
}

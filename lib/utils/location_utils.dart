import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

/// Converts LocationData to Position for app compatibility
Position? _toPosition(LocationData? loc) {
  if (loc == null || loc.latitude == null || loc.longitude == null) return null;

  return Position(
    latitude: loc.latitude!,
    longitude: loc.longitude!,
    timestamp: DateTime.now(),
    accuracy: loc.accuracy ?? 0.0,
    altitude: loc.altitude ?? 0.0,
    heading: loc.heading ?? 0.0,
    speed: loc.speed ?? 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
}

/// Foreground location fetch with UI context and user prompts
Future<Position?> fetchCurrentLocation(BuildContext context) async {
  final location = Location();

  try {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        print('📴 Location services are disabled.');
        return null;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        print('🚫 Location permission denied.');
        return null;
      }
    }

    final currentLocation = await location.getLocation();
    final position = _toPosition(currentLocation);
    print('📍 Foreground Position: $position');
    return position;
  } catch (e) {
    print('❌ Foreground Location error: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Error fetching location')));
    return null;
  }
}

// /// Background-safe location fetch for flutter_foreground_task
// Future<Position?> fetchLocationInForegroundService() async {
//   final location = Location();
//   print("I AM BEING CALLED");
//   try {
//     final serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       print('📴 BG: Location service disabled');
//       return null;
//     }

//     final permission = await location.hasPermission();
//     if (permission != PermissionStatus.granted &&
//         permission != PermissionStatus.grantedLimited) {
//       print('🚫 BG: Location permission not sufficient');
//       return null;
//     }

//     final currentLocation = await location.getLocation();
//     final position = _toPosition(currentLocation);
//     print('📍 FGService Position: $position');
//     return position;
//   } catch (e) {
//     print('❌ FGService Location error: $e');
//     return null;
//   }
// }

/// Background-safe location fetch using geolocator
Future<Position?> fetchLocationInForegroundService() async {
  print("📡 fetchLocationInForegroundService() called");

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('📴 BG: Location service disabled');
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('🚫 BG: Location permission denied');
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      // desiredAccuracy: LocationAccuracy.high,
    );

    print('📍 BG Position: ${position.latitude}, ${position.longitude}');
    return position;
  } catch (e) {
    print('❌ BG Location error: $e');
    return null;
  }
}



// *********************** VEFORE FLUTTER_FOREGROUND_..............
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';

// /// Converts LocationData to Position
// Position? _toPosition(LocationData? loc) {
//   if (loc == null || loc.latitude == null || loc.longitude == null) return null;

//   return Position(
//     latitude: loc.latitude!,
//     longitude: loc.longitude!,
//     timestamp: DateTime.now(),
//     accuracy: loc.accuracy ?? 0.0,
//     altitude: loc.altitude ?? 0.0,
//     heading: loc.heading ?? 0.0,
//     speed: loc.speed ?? 0.0,
//     speedAccuracy: 0.0,
//     altitudeAccuracy: 0.0, // You can customize or extract this if needed
//     headingAccuracy: 0.0,  // Same here
//   );
// }

// /// Foreground location fetch with permission and service prompts
// Future<Position?> fetchCurrentLocation(BuildContext context) async {
//   final location = Location();

//   try {
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location services are disabled.')),
//         );
//         print('📴 Location services are disabled.');
//         return null;
//       }
//     }

//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted &&
//           permissionGranted != PermissionStatus.grantedLimited) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission denied.')),
//         );
//         print('🚫 Location permission denied.');
//         return null;
//       }
//     }

//     final currentLocation = await location.getLocation();
//     final position = _toPosition(currentLocation);
//     print('📍 Foreground Position: $position');
//     return position;
//   } catch (e) {
//     print('❌ Foreground Location error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error fetching location')),
//     );
//     return null;
//   }
// }

// /// Background-friendly location fetch (no UI context)
// Future<Position?> fetchLocationSilently() async {
//   final location = Location();

//   try {
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       print('📴 BG: Location service disabled');
//       return null;
//     }

//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted != PermissionStatus.granted &&
//         permissionGranted != PermissionStatus.grantedLimited) {
//       print('🚫 BG: Location permission not sufficient');
//       return null;
//     }

//     final currentLocation = await location.getLocation();
//     final position = _toPosition(currentLocation);
//     print('📍 BG Position: $position');
//     return position;
//   } catch (e) {
//     print('❌ BG Location error: $e');
//     return null;
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:location/location.dart';

// /// Fetches the current location from the foreground (with UI context).
// /// Prompts user if location service is disabled or permission is denied.
// Future<LocationData?> fetchCurrentLocation(BuildContext context) async {
//   final location = Location();

//   try {
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location services are disabled.')),
//         );
//         print('📴 Location services are disabled.');
//         return null;
//       }
//     }

//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted &&
//           permissionGranted != PermissionStatus.grantedLimited) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission denied.')),
//         );
//         print('🚫 Location permission denied.');
//         return null;
//       }
//     }

//     final currentLocation = await location.getLocation();
//     print('📍 Foreground Location: ${currentLocation.latitude}, ${currentLocation.longitude}');
//     return currentLocation;
//   } catch (e) {
//     print('❌ Foreground Location error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error fetching location')),
//     );
//     return null;
//   }
// }

// /// Fetches the current location silently (used in background tasks).
// /// No UI prompts or interaction, best suited for Workmanager headless tasks.
// Future<LocationData?> fetchLocationSilently() async {
//   final location = Location();

//   try {
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       print('📴 BG: Location service disabled');
//       return null;
//     }

//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted != PermissionStatus.granted &&
//         permissionGranted != PermissionStatus.grantedLimited) {
//       print('🚫 BG: Location permission not sufficient');
//       return null;
//     }

//     final currentLocation = await location.getLocation();
//     print('📍 BG Location: ${currentLocation.latitude}, ${currentLocation.longitude}');
//     return currentLocation;
//   } catch (e) {
//     print('❌ BG Location error: $e');
//     return null;
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// Future<Position?> fetchCurrentLocation(BuildContext context) async {
//   try {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       print('📴 Location services are disabled.');
//       return null;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       print('🚫 Location permission denied.');
//       return null;
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     print('📍 Position: $position');
//     return position;
//   } catch (e) {
//     print('❌ Location error: $e');
//     return null;
//   }
// }

// Future<Position?> fetchLocationSilently() async {
//   try {
//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('📴 BG: Location service disabled');
//       return null;
//     }

//     final permission = await Geolocator.checkPermission();
//     if (permission != LocationPermission.always &&
//         permission != LocationPermission.whileInUse) {
//       print('🚫 BG: Location permission not sufficient');
//       return null;
//     }

//     final position = await Geolocator.getCurrentPosition();
//     print('📍 BG: $position');
//     return position;
//   } catch (e) {
//     print('❌ BG Location error: $e');
//     return null;
//   }
// }

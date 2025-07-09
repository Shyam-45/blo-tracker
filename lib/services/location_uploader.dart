import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:blo_tracker/utils/location_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blo_tracker/services/upload_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blo_tracker/services/location_service.dart';

class LocationUploader {
  static Future<void> sendLocationIfAllowed() async {
    try {
      final now = DateTime.now();
      final isSunday = now.weekday == DateTime.sunday;

      if (isSunday) {
        print("📆 Skipping tracking — it's Sunday.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final disabled = prefs.getBool('user_disabled_today') ?? false;
      final token = prefs.getString('auth_token');

      if (disabled) {
        print("⛔ Tracking disabled by user for today.");
        return;
      }

      if (token == null) {
        print("🚫 No token found, cannot send location.");
        return;
      }

      final shouldTrack = shouldEnforceTrackingNow(disabled);
      if (!shouldTrack) {
        print("⏸️ Skipping tracking — not within tracking hours.");
        return;
      }

      // ✅ Fetch location
      Position? position;
      try {
        position = await fetchLocationSilently();
      } catch (e, stackTrace) {
        print("❌ Exception while fetching location: $e");
        print(stackTrace);
        return;
      }

      if (position == null) {
        print("❌ Failed to fetch background location.");
        return;
      }

      final lat = position.latitude;
      final lon = position.longitude;

      // ✅ Random delay (0–25 sec)
      final delay = Random().nextInt(25);
      print("⏳ Sleeping for $delay seconds before upload.");
      await Future.delayed(Duration(seconds: delay));

      // ✅ Upload to backend
      bool success = false;
      try {
        success = await UploadService.sendBackgroundLocation(
          latitude: lat,
          longitude: lon,
          timestamp: now,
          token: token,
        );
      } catch (e, stackTrace) {
        print("❌ Exception during upload: $e");
        print(stackTrace);
      }

      if (success) {
        print("✅ Location uploaded successfully at $now");

        try {
          await prefs.setString('last_lat', lat.toString());
          await prefs.setString('last_lon', lon.toString());
          await prefs.setString('last_sent_time', now.toIso8601String());
          await prefs.setString('last_location_sent', now.toIso8601String());
        } catch (e) {
          print("⚠️ Failed to save location prefs: $e");
        }
      } else {
        print("❌ Location upload failed.");
      }
    } catch (e, stackTrace) {
      print("💥 Unhandled exception in sendLocationIfAllowed: $e");
      print(stackTrace);
    }
  }
}

// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:blo_tracker/utils/location_utils.dart';
// import 'package:blo_tracker/services/upload_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/utils/location_utils.dart'; // ✅ keep using this if shouldEnforceTrackingNow() lives here
// import 'package:blo_tracker/services/location_service.dart';

// class LocationUploader {
//   static Future<void> sendLocationIfAllowed() async {
//     try {
//       final now = DateTime.now();
//       final isSunday = now.weekday == DateTime.sunday;

//       if (isSunday) {
//         print("📆 Skipping tracking — it's Sunday.");
//         return;
//       }

//       final prefs = await SharedPreferences.getInstance();
//       final disabled = prefs.getBool('user_disabled_today') ?? false;
//       final token = prefs.getString('auth_token');

//       if (disabled) {
//         print("⛔ Tracking disabled by user for today.");
//         return;
//       }

//       if (token == null) {
//         print("🚫 No token found, cannot send location.");
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(disabled);
//       if (!shouldTrack) {
//         print("⏸️ Skipping tracking — not within tracking hours.");
//         return;
//       }

//       // ✅ Try getting location silently
//       Position? position;
//       try {
//         position = await fetchLocationSilently();
//       } catch (e, stackTrace) {
//         print("❌ Exception while fetching location: $e");
//         print(stackTrace);
//         return;
//       }

//       if (position == null) {
//         print("❌ Failed to fetch background location.");
//         return;
//       }

//       final lat = position.latitude;
//       final lon = position.longitude;

//       // ✅ Add random delay (0–25 sec)
//       final delay = Random().nextInt(25);
//       print("⏳ Sleeping for $delay seconds before upload.");
//       await Future.delayed(Duration(seconds: delay));

//       // ✅ Upload logic (commented — test mode)
//       // bool success = false;
//       // try {
//       //   success = await UploadService.sendBackgroundLocation(
//       //     latitude: lat,
//       //     longitude: lon,
//       //     timestamp: now,
//       //     token: token,
//       //   );
//       // } catch (e, stackTrace) {
//       //   print("❌ Exception during upload: $e");
//       //   print(stackTrace);
//       // }

//       // if (success) {
//       //   print("✅ Location uploaded successfully at $now");

//       //   // Save last location data
//       //   await prefs.setString('last_lat', lat.toString());
//       //   await prefs.setString('last_lon', lon.toString());
//       //   await prefs.setString('last_sent_time', now.toIso8601String());
//       //   await prefs.setString('last_location_sent', now.toIso8601String());
//       // } else {
//       //   print("❌ Location upload failed.");
//       // }

//       print("🧪 [Test Mode] Location would be sent now:");
//       print("📍 Latitude: $lat, Longitude: $lon, Timestamp: $now");

//       try {
//         await prefs.setString('last_location_sent', now.toIso8601String());
//       } catch (e) {
//         print("⚠️ Failed to save 'last_location_sent': $e");
//       }
//     } catch (e, stackTrace) {
//       print("💥 Unhandled exception in sendLocationIfAllowed: $e");
//       print(stackTrace);
//     }
//   }
// }

// // class LocationUploader {
// //   static Future<void> sendLocationIfAllowed() async {
// //     final now = DateTime.now();
// //     final isSunday = now.weekday == DateTime.sunday;

// //     if (isSunday) {
// //       print("📆 Skipping tracking — it's Sunday.");
// //       return;
// //     }

// //     final prefs = await SharedPreferences.getInstance();
// //     final disabled = prefs.getBool('user_disabled_today') ?? false;
// //     final token = prefs.getString('auth_token');

// //     if (disabled) {
// //       print("⛔ Tracking disabled by user for today.");
// //       return;
// //     }

// //     if (token == null) {
// //       print("🚫 No token found, cannot send location.");
// //       return;
// //     }

// //     final shouldTrack = shouldEnforceTrackingNow(disabled);
// //     if (!shouldTrack) {
// //       print("⏸️ Skipping tracking — not within tracking hours.");
// //       return;
// //     }

// //     // ✅ Fetch location
// //     final position = await fetchLocationSilently();
// //     if (position == null) {
// //       print("❌ Failed to fetch background location.");
// //       return;
// //     }

// //     final lat = position.latitude;
// //     final lon = position.longitude;

// //     // ✅ Random delay (0–25 sec)
// //     final delay = Random().nextInt(25);
// //     print("⏳ Sleeping for $delay seconds before upload.");
// //     await Future.delayed(Duration(seconds: delay));

// //     // final success = await UploadService.sendBackgroundLocation(
// //     //   latitude: lat,
// //     //   longitude: lon,
// //     //   timestamp: now,
// //     //   token: token,
// //     // );

// //     // if (success) {
// //     //   print("✅ Location uploaded successfully at $now");

// //     //   // ✅ Save last location data for settings screen
// //     //   await prefs.setString('last_lat', lat.toString());
// //     //   await prefs.setString('last_lon', lon.toString());
// //     //   await prefs.setString('last_sent_time', now.toIso8601String());
// //     //   await prefs.setString('last_location_sent', now.toIso8601String()); // Optional, used elsewhere too
// //     // } else {
// //     //   print("❌ Location upload failed.");
// //     // }

// //     print("🧪 [Test Mode] Location would be sent now:");
// //     print("📍 Latitude: $lat, Longitude: $lon, Timestamp: $now");
// //     await prefs.setString('last_location_sent', now.toIso8601String());
// //   }
// // }

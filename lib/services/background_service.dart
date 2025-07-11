import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blo_tracker/services/location_uploader.dart';
import 'package:blo_tracker/services/location_service.dart'; // contains shouldEnforceTrackingNow()

/// Initializes the background service for location tracking
Future<void> initializeBackgroundService() async {
  final prefs = await SharedPreferences.getInstance();
  final userDisabledToday = prefs.getBool('user_disabled_today') ?? false;

  final shouldTrack = await shouldEnforceTrackingNow(userDisabledToday);
  print("📦 BackgroundService: shouldTrack=$shouldTrack");

  if (!shouldTrack) {
    print("⏸️ Not starting service (tracking not required now)");
    return;
  }

  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'blo_tracking_channel',
      initialNotificationTitle: 'BLO Location Service',
      initialNotificationContent: 'Tracking location every 30 minutes',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (_) async => true,
    ),
  );

  final isRunning = await service.isRunning();
  if (!isRunning) {
    await service.startService();
    print("✅ Background service started");
  } else {
    print("🔁 Background service already running");
  }
}

/// Entry point when the background service starts
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  print("🚀 Background service onStart triggered");

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on('stopService').listen((event) {
    print("🛑 Received stopService event");
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 10), (_) async {
    print("📡 Timer tick: trying to upload location every 10 sec");
    await Future.delayed(const Duration(seconds: 2));

    await LocationUploader.sendLocationIfAllowed();
  });
}


// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/location_uploader.dart';
// import 'package:blo_tracker/services/location_service.dart'; // for shouldEnforceTrackingNow

// /// Initializes the background service for location tracking
// Future<void> initializeBackgroundService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'blo_tracking_channel',
//       initialNotificationTitle: 'BLO Location Service',
//       initialNotificationContent: 'Tracking location every 30 minutes',
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: (_) async => true,
//     ),
//   );

//   final prefs = await SharedPreferences.getInstance();
//   final userDisabledToday = prefs.getBool('user_disabled_today') ?? false;

//   final shouldTrack = shouldEnforceTrackingNow(userDisabledToday);
//   print("📦 BackgroundService: shouldTrack=$shouldTrack");

//   if (shouldTrack) {
//     final isRunning = await service.isRunning();
//     if (!isRunning) {
//       await service.startService();
//       print("✅ Background service started");
//     } else {
//       print("🔁 Background service already running");
//     }
//   } else {
//     print("⏸️ Not starting service (tracking not required now)");
//   }
// }

// /// Entry point when the background service starts
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//   print("🚀 Background service onStart triggered");

//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   service.on('stopService').listen((event) {
//     print("🛑 Received stopService event");
//     service.stopSelf();
//   });

//   Timer.periodic(const Duration(seconds: 10), (_) async {
//     print("📡 Timer tick: trying to upload location every 10 sec");
//     await Future.delayed(const Duration(seconds: 2));
//     await LocationUploader.sendLocationIfAllowed();
//   });
// }


// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/location_uploader.dart';

// /// Initializes the background service for location tracking
// Future<void> initializeBackgroundService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'blo_tracking_channel',
//       initialNotificationTitle: 'BLO Location Service',
//       initialNotificationContent: 'Tracking location every 30 minutes',
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: (_) async => true,
//     ),
//   );

//   final prefs = await SharedPreferences.getInstance();
//   final shouldRun = prefs.getBool('user_disabled_today') != true;

//   if (shouldRun) {
//     await service.startService();
//     print("✅ Background service started");
//   } else {
//     print("⏸️ Not starting service (disabled by user)");
//   }
// }

// /// Entry point when the background service starts
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//   print("🚀 Background service onStart triggered");

//   // Ensure foreground service for Android
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   // 🔴 Listen for stop command
//   service.on('stopService').listen((event) {
//     print("🛑 Received stopService event");
//     service.stopSelf();
//   });

//   // 🔁 30-minute periodic location tracking
//   Timer.periodic(const Duration(seconds: 10), (_) async {
//     print("📡 Timer tick: trying to upload location evry 15 sec");
//     await Future.delayed(Duration(seconds: 2)); // important!
//     await LocationUploader.sendLocationIfAllowed();
//   });
// }

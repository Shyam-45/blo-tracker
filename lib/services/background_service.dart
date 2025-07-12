import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blo_tracker/services/location_uploader.dart';
import 'package:blo_tracker/services/location_service.dart'; // shouldEnforceTrackingNow()

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

  scheduleFixedIntervalTracking();
}

/// 📌 Schedules location upload at every 30-minute aligned interval: 9:00, 9:30, 10:00, etc.
void scheduleFixedIntervalTracking() {
  final now = DateTime.now();
  final nextSlot = _getNextAlignedTime(now, 2);
  final initialDelay = nextSlot.difference(now);

  print(
    "⏳ First location upload in ${initialDelay.inSeconds} seconds at $nextSlot",
  );

  Timer(initialDelay, () async {
    print("📡 ⏱️ First 15-min interval upload triggered at ${DateTime.now()}");
    await LocationUploader.sendLocationIfAllowed();

    Timer.periodic(const Duration(minutes: 2), (timer) async {
      print("📡 🔁 Recurring upload triggered at ${DateTime.now()}");
      await LocationUploader.sendLocationIfAllowed();
    });
  });
}

/// Calculates the next aligned time from now for any interval in minutes
DateTime _getNextAlignedTime(DateTime now, int intervalMinutes) {
  final minute = now.minute;
  final nextAlignedMinute = ((minute ~/ intervalMinutes) + 1) * intervalMinutes;

  final nextHour = (nextAlignedMinute >= 60) ? now.hour + 1 : now.hour;
  final alignedMinute = nextAlignedMinute % 60;

  return DateTime(now.year, now.month, now.day, nextHour, alignedMinute);
}


// ****************** 3-MIN Interval code working absolutely fine *********************

// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/location_uploader.dart';
// import 'package:blo_tracker/services/location_service.dart'; // shouldEnforceTrackingNow()

// /// Initializes the background service for location tracking
// Future<void> initializeBackgroundService() async {
//   final prefs = await SharedPreferences.getInstance();
//   final userDisabledToday = prefs.getBool('user_disabled_today') ?? false;

//   final shouldTrack = await shouldEnforceTrackingNow(userDisabledToday);
//   print("📦 BackgroundService: shouldTrack=$shouldTrack");

//   if (!shouldTrack) {
//     print("⏸️ Not starting service (tracking not required now)");
//     return;
//   }

//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'blo_tracking_channel',
//       initialNotificationTitle: 'BLO Location Service',
//       initialNotificationContent: 'Tracking location every 3 minutes',
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: (_) async => true,
//     ),
//   );

//   final isRunning = await service.isRunning();
//   if (!isRunning) {
//     await service.startService();
//     print("✅ Background service started");
//   } else {
//     print("🔁 Background service already running");
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

//   scheduleFixedIntervalTracking();
// }

// /// 📌 Schedules location upload at every 3-minute interval: 9:00, 9:03, 9:06, etc.
// void scheduleFixedIntervalTracking() {
//   final now = DateTime.now();
//   final nextSlot = _getNextAlignedTime(now, 3);
//   final initialDelay = nextSlot.difference(now);

//   print(
//     "⏳ First location upload in ${initialDelay.inSeconds} seconds at $nextSlot",
//   );

//   Timer(initialDelay, () async {
//     print("📡 ⏱️ First 3-min interval upload triggered at ${DateTime.now()}");
//     await LocationUploader.sendLocationIfAllowed();

//     Timer.periodic(const Duration(minutes: 3), (timer) async {
//       print("📡 🔁 Recurring upload triggered at ${DateTime.now()}");
//       await LocationUploader.sendLocationIfAllowed();
//     });
//   });
// }

// /// Calculates the next aligned time from now for any interval in minutes
// DateTime _getNextAlignedTime(DateTime now, int intervalMinutes) {
//   final minute = now.minute;
//   final nextAlignedMinute = ((minute ~/ intervalMinutes) + 1) * intervalMinutes;

//   final nextHour = (nextAlignedMinute >= 60) ? now.hour + 1 : now.hour;
//   final alignedMinute = nextAlignedMinute % 60;

//   return DateTime(now.year, now.month, now.day, nextHour, alignedMinute);
// }


// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/location_uploader.dart';
// import 'package:blo_tracker/services/location_service.dart'; // shouldEnforceTrackingNow()

// /// Initializes the background service for location tracking
// Future<void> initializeBackgroundService() async {
//   final prefs = await SharedPreferences.getInstance();
//   final userDisabledToday = prefs.getBool('user_disabled_today') ?? false;

//   final shouldTrack = await shouldEnforceTrackingNow(userDisabledToday);
//   print("📦 BackgroundService: shouldTrack=$shouldTrack");

//   if (!shouldTrack) {
//     print("⏸️ Not starting service (tracking not required now)");
//     return;
//   }

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

//   final isRunning = await service.isRunning();
//   if (!isRunning) {
//     await service.startService();
//     print("✅ Background service started");
//   } else {
//     print("🔁 Background service already running");
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

//   // Schedule first upload at next fixed 30-min interval
//   scheduleFixedIntervalTracking();
// }

// /// 📌 Schedules location upload at every 9:00, 9:30, 10:00... etc.
// void scheduleFixedIntervalTracking() {
//   final now = DateTime.now();
//   final nextSlot = _getNextHalfHour(now);
//   final initialDelay = nextSlot.difference(now);

//   print("⏳ First location upload in ${initialDelay.inMinutes} minutes at $nextSlot");

//   // ⏱ First upload timer
//   Timer(initialDelay, () async {
//     print("📡 ⏱️ First fixed-interval upload triggered at ${DateTime.now()}");
//     await LocationUploader.sendLocationIfAllowed();

//     // 🔁 Repeat every 30 minutes
//     Timer.periodic(const Duration(minutes: 30), (timer) async {
//       print("📡 🔁 Recurring upload triggered at ${DateTime.now()}");
//       await LocationUploader.sendLocationIfAllowed();
//     });
//   });
// }

// /// Returns the next 30-min aligned time from now
// DateTime _getNextHalfHour(DateTime now) {
//   final minute = now.minute;
//   final nextMinute = (minute < 30) ? 30 : 60;
//   final nextHour = (minute < 30) ? now.hour : now.hour + 1;
//   return DateTime(now.year, now.month, now.day, nextHour, (nextMinute % 60));
// }


// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/location_uploader.dart';
// import 'package:blo_tracker/services/location_service.dart'; // contains shouldEnforceTrackingNow()

// /// Initializes the background service for location tracking
// Future<void> initializeBackgroundService() async {
//   final prefs = await SharedPreferences.getInstance();
//   final userDisabledToday = prefs.getBool('user_disabled_today') ?? false;

//   final shouldTrack = await shouldEnforceTrackingNow(userDisabledToday);
//   print("📦 BackgroundService: shouldTrack=$shouldTrack");

//   if (!shouldTrack) {
//     print("⏸️ Not starting service (tracking not required now)");
//     return;
//   }

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

//   final isRunning = await service.isRunning();
//   if (!isRunning) {
//     await service.startService();
//     print("✅ Background service started");
//   } else {
//     print("🔁 Background service already running");
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

//   Timer.periodic(const Duration(minutes: 30), (_) async {
//     print("📡 Timer tick: trying to upload location every 30 min");
//     await Future.delayed(const Duration(seconds: 2));

//     await LocationUploader.sendLocationIfAllowed();
//   });
// }

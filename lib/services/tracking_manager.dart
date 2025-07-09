import 'package:workmanager/workmanager.dart';

class TrackingManager {
  static const String periodicTaskName = 'location_upload_task';
  static const String oneTimeTaskName = 'resume_location_task';
  static const String testTaskName = 'testTask';
  static const String tag = 'blo_tracking';

  /// Register 30-minute periodic task
  static Future<void> registerPeriodicLocationTask() async {
    print("🔁 Registering periodic task (every 30 mins)");

    await Workmanager().registerPeriodicTask(
      periodicTaskName, // unique name
      periodicTaskName, // task name
      frequency: const Duration(minutes: 30),
      initialDelay: _calculateInitialDelay(),
      tag: tag,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 2),
    );
  }

  /// Trigger one-time task when resuming mid-day
  static Future<void> triggerOneTimeResume() async {
    print("⚡ Triggering one-time resume task");

    await Workmanager().registerOneOffTask(
      oneTimeTaskName,
      oneTimeTaskName,
      tag: tag,
      initialDelay: _calculateInitialDelay(),
    );
  }

  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    print("🛑 Cancelling all background tasks");
    await Workmanager().cancelAll();
  }

  /// TEMP: Test trigger to verify dispatcher
  static Future<void> triggerTestTask() async {
    print("🧪 Triggering test task");

    await Workmanager().registerOneOffTask(
      testTaskName,
      testTaskName,
      initialDelay: const Duration(seconds: 10),
    );
  }

  /// Calculate delay to align with next 30-min mark
  static Duration _calculateInitialDelay() {
    // 🔁 Adjusted for testing (1 minute delay)
    const delay = Duration(minutes: 1);
    print("⏱️ [TEST] Initial delay: ${delay.inMinutes} min");
    return delay;

    // 🔁 Production version:
    // final now = DateTime.now();
    // final minutes = now.minute;
    // final remainder = 30 - (minutes % 30);
    // final next = now.add(Duration(minutes: remainder));
    // final delay = next.difference(now);
    // print("⏱️ Initial delay to next slot: ${delay.inMinutes} min");
    // return delay;
  }
}

  // import 'package:workmanager/workmanager.dart';
// import 'package:blo_tracker/services/location_uploader.dart';

// class TrackingManager {
//   static const String periodicTaskName = 'location_upload_task';
//   static const String oneTimeTaskName = 'resume_location_task';
//   static const String tag = 'blo_tracking';

//   /// Call this once when app launches or after login
//   static Future<void> initialize() async {
//     await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
//   }

//   /// Called only once
//   static Future<void> registerPeriodicLocationTask() async {
//     print("🔁 Registering periodic task (every 30 mins)");

//     await Workmanager().registerPeriodicTask(
//       periodicTaskName,
//       periodicTaskName,
//       frequency: const Duration(minutes: 30),
//       initialDelay: _calculateInitialDelay(),
//       tag: tag,
//       backoffPolicy: BackoffPolicy.exponential,
//       backoffPolicyDelay: const Duration(minutes: 2),
//     );
//   }

//   /// For resuming tracking during same day if user toggles it ON again
//   static Future<void> triggerOneTimeResume() async {
//     print("⚡ Triggering one-time resume task");

//     await Workmanager().registerOneOffTask(
//       oneTimeTaskName,
//       oneTimeTaskName,
//       tag: tag,
//       initialDelay: _calculateInitialDelay(),
//     );
//   }

//   /// Unregisters all tasks (e.g., on logout)
//   static Future<void> cancelAllTasks() async {
//     print("🛑 Cancelling all background tasks");
//     await Workmanager().cancelAll();
//   }

//   /// ⚡ TEMP: Trigger a test one-time task after 10 seconds
//   static Future<void> triggerTestTask() async {
//     print("🧪 Triggering test task");
//     await Workmanager().registerOneOffTask(
//       'testTask', // uniqueName
//       'testTask', // taskName (used in dispatcher)
//       initialDelay: const Duration(seconds: 10),
//     );
//   }

//   // @pragma('vm:entry-point')
//   // /// Used by Workmanager to handle background tasks
//   // static void callbackDispatcher() {
//   //   Workmanager().executeTask((taskName, inputData) async {
//   //     print("📦 Workmanager triggered: $taskName");
//   //     print("📍 LocationUploader.sendLocationIfAllowed() called");

//   //     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//   //       await LocationUploader.sendLocationIfAllowed();
//   //     }

//   //     return Future.value(true);
//   //   });
//   // }
//   @pragma('vm:entry-point')
//   static void callbackDispatcher() {
//     Workmanager().executeTask((taskName, inputData) async {
//       print("📦 Workmanager triggered: $taskName");
//       print("📍 LocationUploader.sendLocationIfAllowed() called");

//       if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//         await LocationUploader.sendLocationIfAllowed();
//       } else if (taskName == 'testTask') {
//         print("🚀 Test task executed!");
//       }

//       return Future.value(true);
//     });
//   }

//   /// Calculate delay to align with next 30-min interval (e.g., 9:00, 9:30, …)
//   // static Duration _calculateInitialDelay() {
//   //   final now = DateTime.now();
//   //   final minutes = now.minute;
//   //   final remainder = 30 - (minutes % 30);
//   //   final next = now.add(Duration(minutes: remainder));

//   //   final delay = next.difference(now);
//   //   print("⏱️ Initial delay to next slot: ${delay.inMinutes} min");

//   //   return delay;
//   // }
//   /// Temporary: For testing only — triggers task in 1 minute
//   static Duration _calculateInitialDelay() {
//     const delay = Duration(minutes: 1); // 🔥 Fire in 1 min for test
//     print("⏱️ [TEST] Initial delay: ${delay.inMinutes} min");
//     return delay;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blo_tracker/screens/splash_screen.dart';
import 'package:blo_tracker/screens/login_screen.dart';
import 'package:blo_tracker/screens/home_screen.dart';
import 'package:blo_tracker/screens/permission_required_screen.dart';
import 'package:blo_tracker/screens/live_screen.dart';
import 'package:blo_tracker/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⏳ Start background service
  // print("⏳ initialised all in main");
  // await initializeBackgroundService();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLO Tracker',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/permission': (_) => const PermissionRequiredScreen(),
        '/live': (_) => const LiveScreen(),
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:workmanager/workmanager.dart';

// import 'package:blo_tracker/screens/splash_screen.dart';
// import 'package:blo_tracker/screens/login_screen.dart';
// import 'package:blo_tracker/screens/home_screen.dart';
// import 'package:blo_tracker/screens/permission_required_screen.dart';
// import 'package:blo_tracker/screens/live_screen.dart';
// import 'package:blo_tracker/services/location_uploader.dart';
// import 'package:blo_tracker/services/foreground_task_handler.dart';

// const String periodicTaskName = 'location_upload_task';
// const String oneTimeTaskName = 'resume_location_task';
// const String testTaskName = 'testTask';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     print("📦 Workmanager triggered: $taskName");

//     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//       print("📍 LocationUploader.sendLocationIfAllowed() called");
//       await LocationUploader.sendLocationIfAllowed();
//     } else if (taskName == testTaskName) {
//       print("🚀 Test task executed!");
//     }

//     return Future.value(true);
//   });
// }

// @pragma('vm:entry-point')
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }

// @pragma('vm:entry-point')
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Initialize Foreground Task with correct eventAction
//   FlutterForegroundTask.init(
//   androidNotificationOptions: AndroidNotificationOptions(
//     channelId: 'location_channel',
//     channelName: 'Background Location',
//     channelDescription: 'Tracks location every 10 seconds (testing)',
//     channelImportance: NotificationChannelImportance.LOW,
//     priority: NotificationPriority.LOW,
//     visibility: NotificationVisibility.VISIBILITY_PUBLIC,
//   ),
//   iosNotificationOptions: const IOSNotificationOptions(),
//   foregroundTaskOptions: ForegroundTaskOptions(
//     eventAction: ForegroundTaskEventAction.repeat(10000), // ✅ Only this is used
//     autoRunOnBoot: false,
//   ),
// );


//   // ✅ Start Foreground Task service
//   await FlutterForegroundTask.startService(
//     notificationTitle: 'BLO Location Service',
//     notificationText: 'Tracking in background...',
//     callback: startCallback,
//   );

//   // ✅ Initialize Workmanager
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLO Survey',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const SplashScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/home': (_) => const HomeScreen(),
//         '/permission': (_) => const PermissionRequiredScreen(),
//         '/live': (_) => const LiveScreen(),
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:workmanager/workmanager.dart';

// import 'package:blo_tracker/screens/splash_screen.dart';
// import 'package:blo_tracker/screens/login_screen.dart';
// import 'package:blo_tracker/screens/home_screen.dart';
// import 'package:blo_tracker/screens/permission_required_screen.dart';
// import 'package:blo_tracker/screens/live_screen.dart';
// import 'package:blo_tracker/services/location_uploader.dart';

// // Constants for task names
// const String periodicTaskName = 'location_upload_task';
// const String oneTimeTaskName = 'resume_location_task';
// const String testTaskName = 'testTask';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     print("📦 Workmanager triggered: $taskName");

//     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//       print("📍 LocationUploader.sendLocationIfAllowed() called");
//       await LocationUploader.sendLocationIfAllowed();
//     } else if (taskName == testTaskName) {
//       print("🚀 Test task executed!");
//     }

//     return Future.value(true);
//   });
// }

// @pragma('vm:entry-point')
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Foreground Task
//   await FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'location_channel',
//       channelName: 'Background Location',
//       channelDescription: 'Tracks location every 10 seconds (testing).',
//       channelImportance: NotificationChannelImportance.LOW,
//       priority: NotificationPriority.LOW,
//       // iconData: const NotificationIconData(
//       //   resType: ResourceType.mipmap,
//       //   resPrefix: ResourcePrefix.ic,
//       //   name: 'launcher',
//       // ),
//       // isSticky: true,
//       visibility: NotificationVisibility.VISIBILITY_PUBLIC,
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(),
//     foregroundTaskOptions: const ForegroundTaskOptions(
//       interval: 10000, // 10 seconds for testing
//       isOnceEvent: false,
//       autoRunOnBoot: false,
//     ),
//   );

//   // Initialize Workmanager
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLO Survey',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const SplashScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/home': (_) => const HomeScreen(),
//         '/permission': (_) => const PermissionRequiredScreen(),
//         '/live': (_) => const LiveScreen(),
//       },
//     );
//   }
// }











// ************************before foreground servicef**************


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:blo_tracker/screens/splash_screen.dart';
// import 'package:blo_tracker/screens/login_screen.dart';
// import 'package:blo_tracker/screens/home_screen.dart';
// import 'package:blo_tracker/screens/permission_required_screen.dart';
// import 'package:blo_tracker/screens/live_screen.dart';
// import 'package:blo_tracker/services/location_uploader.dart';


// // Constants for task names
// const String periodicTaskName = 'location_upload_task';
// const String oneTimeTaskName = 'resume_location_task';
// const String testTaskName = 'testTask';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     print("📦 Workmanager triggered: $taskName");

//     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//       print("📍 LocationUploader.sendLocationIfAllowed() called");
//       await LocationUploader.sendLocationIfAllowed();
//     } else if (taskName == testTaskName) {
//       print("🚀 Test task executed!");
//     }

//     return Future.value(true);
//   });
// }

// @pragma('vm:entry-point')
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLO Survey',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const SplashScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/home': (_) => const HomeScreen(),
//         '/permission': (_) => const PermissionRequiredScreen(),
//         '/live': (_) => const LiveScreen(),
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:workmanager/workmanager.dart';

// import 'package:blo_tracker/screens/splash_screen.dart';
// import 'package:blo_tracker/screens/login_screen.dart';
// import 'package:blo_tracker/screens/home_screen.dart';
// import 'package:blo_tracker/screens/permission_required_screen.dart';
// import 'package:blo_tracker/screens/live_screen.dart';
// import 'package:blo_tracker/services/location_uploader.dart';
// import 'package:blo_tracker/services/foreground_task_handler.dart';

// const String periodicTaskName = 'location_upload_task';
// const String oneTimeTaskName = 'resume_location_task';
// const String testTaskName = 'testTask';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     print("📦 Workmanager triggered: $taskName");

//     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//       print("📍 LocationUploader.sendLocationIfAllowed() called");
//       await LocationUploader.sendLocationIfAllowed();
//     } else if (taskName == testTaskName) {
//       print("🚀 Test task executed!");
//     }

//     return Future.value(true);
//   });
// }

// @pragma('vm:entry-point')
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }

// @pragma('vm:entry-point')
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Initialize Foreground Task with correct eventAction
//   FlutterForegroundTask.init(
//   androidNotificationOptions: AndroidNotificationOptions(
//     channelId: 'location_channel',
//     channelName: 'Background Location',
//     channelDescription: 'Tracks location every 10 seconds (testing)',
//     channelImportance: NotificationChannelImportance.LOW,
//     priority: NotificationPriority.LOW,
//     visibility: NotificationVisibility.VISIBILITY_PUBLIC,
//   ),
//   iosNotificationOptions: const IOSNotificationOptions(),
//   foregroundTaskOptions: ForegroundTaskOptions(
//     eventAction: ForegroundTaskEventAction.repeat(10000), // ✅ Only this is used
//     autoRunOnBoot: false,
//   ),
// );


//   // ✅ Start Foreground Task service
//   await FlutterForegroundTask.startService(
//     notificationTitle: 'BLO Location Service',
//     notificationText: 'Tracking in background...',
//     callback: startCallback,
//   );

//   // ✅ Initialize Workmanager
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLO Survey',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const SplashScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/home': (_) => const HomeScreen(),
//         '/permission': (_) => const PermissionRequiredScreen(),
//         '/live': (_) => const LiveScreen(),
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:workmanager/workmanager.dart';

// import 'package:blo_tracker/screens/splash_screen.dart';
// import 'package:blo_tracker/screens/login_screen.dart';
// import 'package:blo_tracker/screens/home_screen.dart';
// import 'package:blo_tracker/screens/permission_required_screen.dart';
// import 'package:blo_tracker/screens/live_screen.dart';
// import 'package:blo_tracker/services/location_uploader.dart';

// // Constants for task names
// const String periodicTaskName = 'location_upload_task';
// const String oneTimeTaskName = 'resume_location_task';
// const String testTaskName = 'testTask';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     print("📦 Workmanager triggered: $taskName");

//     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//       print("📍 LocationUploader.sendLocationIfAllowed() called");
//       await LocationUploader.sendLocationIfAllowed();
//     } else if (taskName == testTaskName) {
//       print("🚀 Test task executed!");
//     }

//     return Future.value(true);
//   });
// }

// @pragma('vm:entry-point')
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Foreground Task
//   await FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'location_channel',
//       channelName: 'Background Location',
//       channelDescription: 'Tracks location every 10 seconds (testing).',
//       channelImportance: NotificationChannelImportance.LOW,
//       priority: NotificationPriority.LOW,
//       // iconData: const NotificationIconData(
//       //   resType: ResourceType.mipmap,
//       //   resPrefix: ResourcePrefix.ic,
//       //   name: 'launcher',
//       // ),
//       // isSticky: true,
//       visibility: NotificationVisibility.VISIBILITY_PUBLIC,
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(),
//     foregroundTaskOptions: const ForegroundTaskOptions(
//       interval: 10000, // 10 seconds for testing
//       isOnceEvent: false,
//       autoRunOnBoot: false,
//     ),
//   );

//   // Initialize Workmanager
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLO Survey',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const SplashScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/home': (_) => const HomeScreen(),
//         '/permission': (_) => const PermissionRequiredScreen(),
//         '/live': (_) => const LiveScreen(),
//       },
//     );
//   }
// }











// ************************before foreground servicef**************


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:blo_tracker/screens/splash_screen.dart';
// import 'package:blo_tracker/screens/login_screen.dart';
// import 'package:blo_tracker/screens/home_screen.dart';
// import 'package:blo_tracker/screens/permission_required_screen.dart';
// import 'package:blo_tracker/screens/live_screen.dart';
// import 'package:blo_tracker/services/location_uploader.dart';


// // Constants for task names
// const String periodicTaskName = 'location_upload_task';
// const String oneTimeTaskName = 'resume_location_task';
// const String testTaskName = 'testTask';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     print("📦 Workmanager triggered: $taskName");

//     if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
//       print("📍 LocationUploader.sendLocationIfAllowed() called");
//       await LocationUploader.sendLocationIfAllowed();
//     } else if (taskName == testTaskName) {
//       print("🚀 Test task executed!");
//     }

//     return Future.value(true);
//   });
// }

// @pragma('vm:entry-point')
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLO Survey',
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const SplashScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/home': (_) => const HomeScreen(),
//         '/permission': (_) => const PermissionRequiredScreen(),
//         '/live': (_) => const LiveScreen(),
//       },
//     );
//   }
// }

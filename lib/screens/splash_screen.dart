import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:blo_tracker/services/location_service.dart';
import 'package:blo_tracker/services/background_service.dart';
import 'package:blo_tracker/providers/app_state_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    Future.microtask(() async {
      print("🌀 SplashScreen logic started");

      if (!appState.isLoggedIn) {
        print("🔐 User not logged in → navigating to /login");
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);
      print("📍 Should enforce tracking now: $shouldTrack");

      if (shouldTrack) {
        final permission = await Geolocator.checkPermission();
        print("🔍 Location permission: $permission");

        if (permission != LocationPermission.always) {
          print("❗ Background location permission missing → navigating to /permission");
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/permission');
          return;
        }

        // ✅ Background permission is granted — ensure service is running
        final service = FlutterBackgroundService();
        final isRunning = await service.isRunning();
        print("🛰️ Background service running: $isRunning");

        if (!isRunning) {
          print("🟢 Starting background service now...");
          await initializeBackgroundService();
        } else {
          print("✅ Background service already running");
        }
      } else {
        print("⏸️ Tracking not required now — skipping service start");
      }

      print("✅ All good → navigating to /home");
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       print("🌀 SplashScreen logic started");

//       if (!appState.isLoggedIn) {
//         print("🔐 User not logged in → navigating to /login");
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);
//       print("📍 Should enforce tracking now: $shouldTrack");

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         print("🔍 Location permission: $permission");

//         if (permission != LocationPermission.always) {
//           print("❗ Background location permission missing → navigating to /permission");
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }

//         // ✅ Background permission is granted — ensure service is running
//         final service = FlutterBackgroundService();
//         final isRunning = await service.isRunning();
//         print("🛰️ Background service running: $isRunning");

//         if (!isRunning) {
//           print("🟢 Starting background service now...");
//           await initializeBackgroundService();
//         } else {
//           print("✅ Background service already running");
//         }
//       } else {
//         print("⏸️ Tracking not required now — skipping service start");
//       }

//       print("✅ All good → navigating to /home");
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       print("🌀 SplashScreen logic started");

//       if (!appState.isLoggedIn) {
//         print("🔐 User not logged in → navigating to /login");
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);
//       print("📍 Should enforce tracking now: $shouldTrack");

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         print("🔍 Location permission: $permission");

//         if (permission != LocationPermission.always) {
//           print("❗ Background location permission missing → navigating to /permission");
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }
//       }

//       print("✅ All good → navigating to /home");
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       if (!appState.isLoggedIn) {
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         if (permission != LocationPermission.always) {
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }
//       }
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }



// ***************** ONLY TO FIX LOADING not appearing ****************************

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       print("🌀 SplashScreen logic started");

//       if (!appState.isLoggedIn) {
//         print("🔐 User not logged in → navigating to /login");
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);
//       print("📍 Should enforce tracking now: $shouldTrack");

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         print("🔍 Location permission: $permission");

//         if (permission != LocationPermission.always) {
//           print("❗ Background location permission missing → navigating to /permission");
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }

//         // ✅ Background permission is granted — ensure service is running
//         final service = FlutterBackgroundService();
//         final isRunning = await service.isRunning();
//         print("🛰️ Background service running: $isRunning");

//         if (!isRunning) {
//           print("🟢 Starting background service now...");
//           await initializeBackgroundService();
//         } else {
//           print("✅ Background service already running");
//         }
//       } else {
//         print("⏸️ Tracking not required now — skipping service start");
//       }

//       print("✅ All good → navigating to /home");
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       print("🌀 SplashScreen logic started");

//       if (!appState.isLoggedIn) {
//         print("🔐 User not logged in → navigating to /login");
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);
//       print("📍 Should enforce tracking now: $shouldTrack");

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         print("🔍 Location permission: $permission");

//         if (permission != LocationPermission.always) {
//           print("❗ Background location permission missing → navigating to /permission");
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }

//         // ✅ Background permission is granted — ensure service is running
//         final service = FlutterBackgroundService();
//         final isRunning = await service.isRunning();
//         print("🛰️ Background service running: $isRunning");

//         if (!isRunning) {
//           print("🟢 Starting background service now...");
//           await initializeBackgroundService();
//         } else {
//           print("✅ Background service already running");
//         }
//       } else {
//         print("⏸️ Tracking not required now — skipping service start");
//       }

//       print("✅ All good → navigating to /home");
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       print("🌀 SplashScreen logic started");

//       if (!appState.isLoggedIn) {
//         print("🔐 User not logged in → navigating to /login");
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);
//       print("📍 Should enforce tracking now: $shouldTrack");

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         print("🔍 Location permission: $permission");

//         if (permission != LocationPermission.always) {
//           print("❗ Background location permission missing → navigating to /permission");
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }
//       }

//       print("✅ All good → navigating to /home");
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:blo_tracker/services/location_service.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';

// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appStateProvider);
//     final notifier = ref.read(appStateProvider.notifier);

//     Future.microtask(() async {
//       if (!appState.isLoggedIn) {
//         if (!context.mounted) return;
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final shouldTrack = shouldEnforceTrackingNow(appState.userDisabledToday);

//       if (shouldTrack) {
//         final permission = await Geolocator.checkPermission();
//         if (permission != LocationPermission.always) {
//           if (!context.mounted) return;
//           Navigator.pushReplacementNamed(context, '/permission');
//           return;
//         }
//       }
//       if (!context.mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     });

//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

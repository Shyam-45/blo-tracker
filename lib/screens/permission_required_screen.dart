import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blo_tracker/services/tracking_manager.dart';

class PermissionRequiredScreen extends StatefulWidget {
  const PermissionRequiredScreen({super.key});

  @override
  State<PermissionRequiredScreen> createState() =>
      _PermissionRequiredScreenState();
}

class _PermissionRequiredScreenState extends State<PermissionRequiredScreen>
    with WidgetsBindingObserver {
  bool _hasStartedTracking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndProceed(); // ⏱️ Optional: auto-check if resumed doesn't fire
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndProceed();
    }
  }

  Future<void> _checkPermissionAndProceed() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always && !_hasStartedTracking) {
      print("🟢 Background permission granted!");

      _hasStartedTracking = true; // prevent duplicate calls

      await TrackingManager.registerPeriodicLocationTask();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print("🔴 Background permission NOT granted yet.");
    }
  }

  Future<void> _openSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permission Required")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "To continue, you must allow background location access:\n\n"
              "Go to App Settings → Permissions → Location → Allow all the time",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
              label: const Text("Open App Settings"),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:blo_tracker/services/tracking_manager.dart';

// class PermissionRequiredScreen extends StatefulWidget {
//   const PermissionRequiredScreen({super.key});

//   @override
//   State<PermissionRequiredScreen> createState() => _PermissionRequiredScreenState();
// }

// class _PermissionRequiredScreenState extends State<PermissionRequiredScreen>
//     with WidgetsBindingObserver {

//   bool _isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed && !_isProcessing) {
//       _isProcessing = true;

//       final permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.always) {
//         print("🟢 Background permission granted!");

//         // ✅ Register periodic background tracking task
//         await TrackingManager.registerPeriodicLocationTask();

//         if (!mounted) return;
//         Navigator.pushReplacementNamed(context, '/home');
//       } else {
//         print("🔴 Background permission NOT granted yet.");
//       }

//       _isProcessing = false;
//     }
//   }

//   Future<void> _openSettings() async {
//     await Geolocator.openAppSettings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Background Permission Required")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.location_on, size: 80, color: Colors.red),
//             const SizedBox(height: 20),
//             const Text(
//               "This app needs background location access to function properly.\n\n"
//               "We use it to record your location automatically every 30 minutes "
//               "during working hours (9:00 AM – 6:00 PM), so that your field activity can be tracked accurately.\n\n"
//               "You will not be tracked outside work hours or on Sundays.",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _openSettings,
//               icon: const Icon(Icons.settings),
//               label: const Text("Open App Settings"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

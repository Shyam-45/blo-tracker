import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:blo_tracker/services/background_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isTrackingDisabled = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _resetTrackingIfNewDay().then((_) => _loadToggleState());
  }

  /// 🔁 Auto-reset toggle at start of new day (Mon–Sat)
  Future<void> _resetTrackingIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpened = prefs.getString('last_opened_date');

    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;
    final todayKey = "${now.year}-${now.month}-${now.day}";

    if (!isSunday && lastOpened != todayKey) {
      await prefs.setBool('user_disabled_today', false);
      await prefs.setString('last_opened_date', todayKey);
      print("🔁 Auto-reset tracking toggle (new day)");
    }
  }

  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('user_disabled_today') ?? false;
    setState(() {
      isTrackingDisabled = value;
    });
  }

  bool isWithinAllowedTrackingWindow() {
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;
    final start = DateTime(now.year, now.month, now.day, 8, 45);
    final end = DateTime(now.year, now.month, now.day, 18, 15);
    return !isSunday && now.isAfter(start) && now.isBefore(end);
  }

  Future<void> _toggleTracking(bool value) async {
    if (_isProcessing) return;

    if (!isWithinAllowedTrackingWindow()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tracking can only be toggled between 8:45 AM and 6:15 PM (Mon–Sat)."),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_disabled_today', value);

    if (value) {
      print("🛑 User disabled tracking. Stopping service...");
      FlutterBackgroundService().invoke("stopService");
    } else {
      print("✅ User enabled tracking. Starting service...");
      await initializeBackgroundService();
    }

    setState(() {
      isTrackingDisabled = value;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: isTrackingDisabled,
              onChanged: _isProcessing ? null : _toggleTracking,
              title: const Text("Disable Location Tracking for Today"),
              subtitle: const Text("Use this if you're on leave today"),
              // secondary: const Icon(Icons.toggle_off_outlined),
            ),
            const SizedBox(height: 24),
            const Text(
              "📋 Tracking Rules:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("• Tracking happens only between 9:00 AM to 6:15 PM, Monday to Saturday.",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text("• No tracking on Sunday.", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              "• You can disable tracking anytime between 8:45 AM and 6:15 PM on valid days.",
              style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              "• If you disable tracking, it will be auto-enabled the next day (except Sunday). For Sunday, it resets on Monday.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isTrackingDisabled = false;
//   bool _isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     _resetTrackingIfNewDay();
//     _loadToggleState();
//   }

//   /// 🔁 Reset toggle at start of new day (only Mon–Sat)
//   Future<void> _resetTrackingIfNewDay() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastOpened = prefs.getString('last_opened_date');

//     final now = DateTime.now();
//     final isSunday = now.weekday == DateTime.sunday;
//     final todayString = "${now.year}-${now.month}-${now.day}";

//     if (!isSunday && lastOpened != todayString) {
//       await prefs.setBool('user_disabled_today', false);
//       await prefs.setString('last_opened_date', todayString);
//       print("🔁 Auto-reset tracking toggle (new day)");
//     }
//   }

//   Future<void> _loadToggleState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
//     });
//   }

//   bool isWithinAllowedTrackingWindow() {
//     final now = DateTime.now();
//     final isSunday = now.weekday == DateTime.sunday;
//     final start = DateTime(now.year, now.month, now.day, 0, 18);
//     final end = DateTime(now.year, now.month, now.day, 23, 59);
//     return !isSunday && now.isAfter(start) && now.isBefore(end);
//   }

//   Future<void> _toggleTracking(bool value) async {
//     if (_isProcessing) return;

//     if (!isWithinAllowedTrackingWindow()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "Tracking can only be toggled between 9:00 AM and 6:30 PM (Mon–Sat).",
//           ),
//         ),
//       );
//       return;
//     }

//     _isProcessing = true;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('user_disabled_today', value);

//     setState(() {
//       isTrackingDisabled = value;
//     });

//     if (value) {
//       print("🛑 User disabled tracking. Stopping service...");
//       FlutterBackgroundService().invoke("stopService");
//     } else {
//       print("✅ User enabled tracking. Starting service...");
//       await initializeBackgroundService();
//     }

//     _isProcessing = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const Icon(Icons.location_on, size: 64, color: Colors.blue),
//             // const SizedBox(height: 16),
//             SwitchListTile(
//               value: isTrackingDisabled,
//               onChanged: _isProcessing ? null : _toggleTracking,
//               title: const Text("Disable Location Tracking for Today"),
//               subtitle: const Text("Use this if you're on leave today"),
//               secondary: const Icon(Icons.toggle_off_outlined),
//             ),

//             const SizedBox(height: 24),
//             const Text(
//               "📋 Tracking Rules:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               "• Tracking happens only between 9:00 AM to 6:30 PM, Monday to Saturday.",
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "• No tracking on Sunday.",
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "• You can disable tracking anytime between 9:00 AM and 6:30 PM on valid days",
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "• If you disable tracking, it will be auto-enabled the next day (except Sunday). In case of Sunday, it will be renabled on Monday.",
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isTrackingDisabled = false;
//   bool _isProcessing = false;
//   Timer? _countdownTimer;
//   Duration _timeLeft = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _loadToggleState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadToggleState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
//     });
//   }

//   bool isWithinAllowedTrackingWindow() {
//     final now = DateTime.now();
//     final isSunday = now.weekday == DateTime.sunday;
//     final start = DateTime(now.year, now.month, now.day, 9, 0);
//     final end = DateTime(now.year, now.month, now.day, 18, 30);
//     return !isSunday && now.isAfter(start) && now.isBefore(end);
//   }

//   Future<void> _toggleTracking(bool value) async {
//     if (_isProcessing) return;
//     if (!isWithinAllowedTrackingWindow()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Tracking can only be toggled between 9:00 AM and 6:30 PM (Mon–Sat)."),
//         ),
//       );
//       return;
//     }

//     _isProcessing = true;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('user_disabled_today', value);

//     setState(() {
//       isTrackingDisabled = value;
//     });

//     if (value) {
//       print("🛑 User disabled tracking. Stopping service...");
//       FlutterBackgroundService().invoke("stopService");
//     } else {
//       print("✅ User enabled tracking. Starting service...");
//       await initializeBackgroundService();
//     }

//     _isProcessing = false;
//   }

//   void _startCountdown() {
//     _updateTimeLeft();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _updateTimeLeft();
//     });
//   }

//   void _updateTimeLeft() {
//     final now = DateTime.now();
//     final nextSlotMinute = now.minute < 30 ? 30 : 60;
//     final nextSlot = DateTime(now.year, now.month, now.day, now.hour, nextSlotMinute);
//     final remaining = nextSlot.difference(now);

//     setState(() {
//       _timeLeft = remaining;
//     });
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Icon(Icons.location_on, size: 64, color: Colors.blue),
//             const SizedBox(height: 16),
//             const Text(
//               "This app collects your location every 30 minutes between 9:00 AM and 6:00 PM "
//               "to ensure field visits are being performed as per schedule. "
//               "You can turn off tracking for the day if you're on leave.",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             SwitchListTile(
//               value: isTrackingDisabled,
//               onChanged: _isProcessing ? null : _toggleTracking,
//               title: const Text("Disable Location Tracking for Today"),
//               subtitle: const Text("Use this if you're on leave today"),
//               secondary: const Icon(Icons.toggle_off_outlined),
//             ),
//             const SizedBox(height: 30),
//             if (!isTrackingDisabled)
//               Column(
//                 children: [
//                   const Text(
//                     "Next location update in:",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _formatDuration(_timeLeft),
//                     style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isTrackingDisabled = false;
//   bool _isProcessing = false;
//   Timer? _countdownTimer;
//   Duration _timeLeft = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _loadToggleState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadToggleState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
//     });
//   }

//   Future<void> _toggleTracking(bool value) async {
//     if (_isProcessing) return;
//     _isProcessing = true;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('user_disabled_today', value);

//     setState(() {
//       isTrackingDisabled = value;
//     });

//     if (value) {
//       // 🛑 Stop service
//       print("🛑 User disabled tracking. Stopping service...");
//       FlutterBackgroundService().invoke("stopService");
//     } else {
//       // ✅ Start service
//       print("✅ User enabled tracking. Starting service...");
//       await initializeBackgroundService();
//     }

//     _isProcessing = false;
//   }

//   void _startCountdown() {
//     _updateTimeLeft();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _updateTimeLeft();
//     });
//   }

//   void _updateTimeLeft() {
//     final now = DateTime.now();
//     final nextSlotMinute = now.minute < 30 ? 30 : 60;
//     final nextSlot = DateTime(now.year, now.month, now.day, now.hour, nextSlotMinute);
//     final remaining = nextSlot.difference(now);

//     setState(() {
//       _timeLeft = remaining;
//     });
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Icon(Icons.location_on, size: 64, color: Colors.blue),
//             const SizedBox(height: 16),
//             const Text(
//               "This app collects your location every 30 minutes between 9:00 AM and 6:00 PM "
//               "to ensure field visits are being performed as per schedule. "
//               "You can turn off tracking for the day if you're on leave.",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             SwitchListTile(
//               value: isTrackingDisabled,
//               onChanged: _isProcessing ? null : _toggleTracking,
//               title: const Text("Disable Location Tracking for Today"),
//               subtitle: const Text("Use this if you're on leave today"),
//               secondary: const Icon(Icons.toggle_off_outlined),
//             ),
//             const SizedBox(height: 30),
//             if (!isTrackingDisabled)
//               Column(
//                 children: [
//                   const Text(
//                     "Next location update in:",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _formatDuration(_timeLeft),
//                     style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/background_service.dart'; // Make sure this is the correct import
// import 'package:flutter_background_service/flutter_background_service.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isTrackingDisabled = false;
//   Timer? _countdownTimer;
//   Duration _timeLeft = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _loadToggleState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadToggleState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
//     });
//   }

//   Future<void> _toggleTracking(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('user_disabled_today', value);
//     setState(() {
//       isTrackingDisabled = value;
//     });

//     if (value) {
//       // 🛑 Stop background service
//       FlutterBackgroundService().invoke("stopService");
//       print("🛑 Requested background service to stop");
//     } else {
//       // ✅ Start/restart background service
//       await initializeBackgroundService();
//       print("✅ Requested background service to start");
//     }
//   }

//   void _startCountdown() {
//     _updateTimeLeft();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _updateTimeLeft();
//     });
//   }

//   void _updateTimeLeft() {
//     final now = DateTime.now();
//     final nextSlotMinute = now.minute < 30 ? 30 : 60;
//     final nextSlot = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       now.hour,
//       nextSlotMinute,
//     );
//     final remaining = nextSlot.difference(now);

//     setState(() {
//       _timeLeft = remaining;
//     });
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Icon(Icons.location_on, size: 64, color: Colors.blue),
//             const SizedBox(height: 16),
//             const Text(
//               "This app collects your location every 30 minutes between 9:00 AM and 6:00 PM "
//               "to ensure field visits are being performed as per schedule. "
//               "You can turn off tracking for the day if you're on leave.",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             SwitchListTile(
//               value: isTrackingDisabled,
//               onChanged: _toggleTracking,
//               title: const Text("Disable Location Tracking for Today"),
//               subtitle: const Text("Use this if you're on leave today"),
//               secondary: const Icon(Icons.toggle_off_outlined),
//             ),
//             const SizedBox(height: 30),
//             if (!isTrackingDisabled)
//               Column(
//                 children: [
//                   const Text(
//                     "Next location update in:",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _formatDuration(_timeLeft),
//                     style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// // lib/screens/settings_screen.dart

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';


// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isTrackingDisabled = false;
//   Timer? _countdownTimer;
//   Duration _timeLeft = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _loadToggleState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadToggleState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
//     });
//   }

//   Future<void> _toggleTracking(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('user_disabled_today', value);
//     setState(() {
//       isTrackingDisabled = value;
//     });

//     if (value) {
//       // User disabled tracking
//       // await FlutterBackgroundService().invoke("stopService");
//       FlutterBackgroundService().invoke("stopService");

//       print("🛑 User disabled tracking, service stopped");
//     } else {
//       // User enabled tracking
//       await initializeBackgroundService();
//       print("✅ User enabled tracking, service started");
//     }
//   }

//   void _startCountdown() {
//     _updateTimeLeft();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _updateTimeLeft();
//     });
//   }

//   void _updateTimeLeft() {
//     final now = DateTime.now();
//     final nextSlotMinute = now.minute < 30 ? 30 : 60;
//     final nextSlot = DateTime(now.year, now.month, now.day, now.hour, nextSlotMinute);
//     final remaining = nextSlot.difference(now);

//     setState(() {
//       _timeLeft = remaining;
//     });
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Icon(Icons.location_on, size: 64, color: Colors.blue),
//             const SizedBox(height: 16),
//             const Text(
//               "This app collects your location every 30 minutes between 9:00 AM and 6:00 PM.\n"
//               "You can disable it for today if you're on leave.",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             SwitchListTile(
//               value: isTrackingDisabled,
//               onChanged: _toggleTracking,
//               title: const Text("Disable Tracking for Today"),
//               subtitle: const Text("Use if you're on leave today"),
//               secondary: const Icon(Icons.toggle_off_outlined),
//             ),
//             const SizedBox(height: 30),
//             if (!isTrackingDisabled)
//               Column(
//                 children: [
//                   const Text("Next update in:", style: TextStyle(fontSize: 16)),
//                   const SizedBox(height: 8),
//                   Text(
//                     _formatDuration(_timeLeft),
//                     style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:async';
// // import 'package:blo_tracker/utils/tracking_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:blo_tracker/services/tracking_manager.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isTrackingDisabled = false;
//   Timer? _countdownTimer;
//   Duration _timeLeft = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _loadToggleState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadToggleState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
//     });
//   }

//   Future<void> _toggleTracking(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('user_disabled_today', value);
//     setState(() {
//       isTrackingDisabled = value;
//     });
//   }

//   void _startCountdown() {
//     _updateTimeLeft();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _updateTimeLeft();
//     });
//   }

//   void _updateTimeLeft() {
//     final now = DateTime.now();
//     final nextSlotMinute = now.minute < 30 ? 30 : 60;
//     final nextSlot = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       now.hour,
//       nextSlotMinute,
//     );
//     final remaining = nextSlot.difference(now);

//     setState(() {
//       _timeLeft = remaining;
//     });
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Icon(Icons.location_on, size: 64, color: Colors.blue),
//             const SizedBox(height: 16),
//             const Text(
//               "This app collects your location every 30 minutes between 9:00 AM and 6:00 PM "
//               "to ensure field visits are being performed as per schedule. "
//               "You can turn off tracking for the day if you're on leave.",
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             SwitchListTile(
//               value: isTrackingDisabled,
//               onChanged: _toggleTracking,
//               title: const Text("Disable Location Tracking for Today"),
//               subtitle: const Text("Use this if you're on leave today"),
//               secondary: const Icon(Icons.toggle_off_outlined),
//             ),
//             const SizedBox(height: 30),
//             if (!isTrackingDisabled)
//               Column(
//                 children: [
//                   const Text(
//                     "Next location update in:",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _formatDuration(_timeLeft),
//                     style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 await TrackingManager.triggerTestTask();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('🧪 Test task will trigger in 10 seconds'),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.bug_report),
//               label: const Text("Trigger Test Background Task"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

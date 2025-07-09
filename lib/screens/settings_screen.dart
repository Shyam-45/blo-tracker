import 'dart:async';
// import 'package:blo_tracker/utils/tracking_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blo_tracker/services/tracking_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isTrackingDisabled = false;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadToggleState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isTrackingDisabled = prefs.getBool('user_disabled_today') ?? false;
    });
  }

  Future<void> _toggleTracking(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_disabled_today', value);
    setState(() {
      isTrackingDisabled = value;
    });
  }

  void _startCountdown() {
    _updateTimeLeft();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    final nextSlotMinute = now.minute < 30 ? 30 : 60;
    final nextSlot = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      nextSlotMinute,
    );
    final remaining = nextSlot.difference(now);

    setState(() {
      _timeLeft = remaining;
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.location_on, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              "This app collects your location every 30 minutes between 9:00 AM and 6:00 PM "
              "to ensure field visits are being performed as per schedule. "
              "You can turn off tracking for the day if you're on leave.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              value: isTrackingDisabled,
              onChanged: _toggleTracking,
              title: const Text("Disable Location Tracking for Today"),
              subtitle: const Text("Use this if you're on leave today"),
              secondary: const Icon(Icons.toggle_off_outlined),
            ),
            const SizedBox(height: 30),
            if (!isTrackingDisabled)
              Column(
                children: [
                  const Text(
                    "Next location update in:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_timeLeft),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ElevatedButton.icon(
              onPressed: () async {
                await TrackingManager.triggerTestTask();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🧪 Test task will trigger in 10 seconds'),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text("Trigger Test Background Task"),
            ),
          ],
        ),
      ),
    );
  }
}

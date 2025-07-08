// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:blo_tracker/models/live_entry_model.dart';
// import 'package:blo_tracker/screens/upload_details_screen.dart';
// import 'package:blo_tracker/utils/time_window_utils.dart';
// import 'package:blo_tracker/db/local_db.dart';

// class LiveScreen extends StatefulWidget {
//   const LiveScreen({super.key});

//   @override
//   State<LiveScreen> createState() => _LiveScreenState();
// }

// class _LiveScreenState extends State<LiveScreen> {
//   List<LiveEntry> _entries = [];
//   LiveEntry? _lastUpdatedEntry;

//   @override
//   void initState() {
//     super.initState();
//     _loadEntries();
//   }

//   Future<void> _loadEntries() async {
//     final allEntries = await LocalDb.getEntriesForToday();
//     final now = DateTime.now();

//     setState(() {
//       _entries = allEntries;
//       _lastUpdatedEntry = allEntries
//           .where((e) => e.isSubmitted)
//           .fold<LiveEntry?>(null, (prev, current) {
//             if (prev == null) return current;
//             return current.timeSlot.isAfter(prev.timeSlot) ? current : prev;
//           });
//     });
//   }

//   // void _navigateToUpload(TimeWindow window) async {
//   //   final result = await Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (_) => UploadDetailsScreen(timeWindow: window),
//   //     ),
//   //   );

//   //   if (result == true) {
//   //     _loadEntries(); // Refresh entries
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final allWindows = getTimeWindows(now);

//     final past = allWindows.where((w) => w.end.isBefore(now)).toList();
//     final future = allWindows.where((w) => w.start.isAfter(now)).toList();
//     final currentWindow = getCurrentAllowedWindow(now);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Live Tracker')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_lastUpdatedEntry != null)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blueAccent),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Last Updated Location",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Latitude: ${_lastUpdatedEntry!.latitude?.toStringAsFixed(4) ?? 'N/A'}",
//                     ),
//                     Text(
//                       "Longitude: ${_lastUpdatedEntry!.longitude?.toStringAsFixed(4) ?? 'N/A'}",
//                     ),
//                     Text(
//                       "Time: ${DateFormat('hh:mm a').format(_lastUpdatedEntry!.timeSlot)}",
//                     ),
//                   ],
//                 ),
//               ),
//             if (currentWindow != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Current Active Slot: ${currentWindow.label}",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton.icon(
//                     // onPressed: () => _navigateToUpload(currentWindow),
//                     icon: const Icon(Icons.edit_location_alt),
//                     label: const Text("Upload Details"),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             const Text(
//               "Upcoming Entries",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             ...future.map(
//               (slot) => ListTile(
//                 title: Text(slot.label),
//                 subtitle: const Text("Not available yet"),
//                 trailing: const Icon(Icons.schedule),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Past Entries",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             ...past.map((slot) {
//               final entry = _entries.firstWhere(
//                 (e) => e.timeSlot.hour == slot.start.hour,
//                 orElse: () => LiveEntry(
//                   timeSlot: slot.start,
//                   isSubmitted: false,
//                   isMissed: true,
//                 ),
//               );
//               return ListTile(
//                 title: Text(slot.label),
//                 subtitle: Text(entry.isSubmitted ? "Done" : "Missed"),
//                 trailing: Icon(
//                   entry.isSubmitted ? Icons.check_circle : Icons.cancel,
//                   color: entry.isSubmitted ? Colors.green : Colors.red,
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:blo_tracker/utils/time_window_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/upload_details_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  String? lastLocation;
  List<String> completedSlots = [];
  DateTime now = DateTime.now();
  TimeWindow? currentWindow;

  @override
  void initState() {
    super.initState();
    loadLastLocation();
    currentWindow = getCurrentAllowedWindow(now);
  }

  Future<void> loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString('last_location_sent');
    final completed = prefs.getStringList('completed_slots') ?? [];
    setState(() {
      lastLocation = location;
      completedSlots = completed;
    });
  }

  Future<void> saveCompletedSlot(String label) async {
    final prefs = await SharedPreferences.getInstance();
    completedSlots.add(label);
    await prefs.setStringList('completed_slots', completedSlots);
  }

  @override
  Widget build(BuildContext context) {
    final timeWindows = getTimeWindows(now);

    final upcoming = timeWindows
        .where((w) => now.isBefore(w.end) && !completedSlots.contains(w.label))
        .toList();

    final past = timeWindows
        .where((w) => now.isAfter(w.end))
        .map(
          (w) => {
            'label': w.label,
            'status': completedSlots.contains(w.label) ? 'Done' : 'Missed',
          },
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Updated Location:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(lastLocation ?? 'No location sent yet.'),
            const Divider(height: 30),
            if (currentWindow != null &&
                !completedSlots.contains(currentWindow!.label))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Entry: ${currentWindow!.label}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UploadDetailsScreen(label: currentWindow!.label),
                        ),
                      );
                      if (result != null && result == 'uploaded') {
                        await saveCompletedSlot(currentWindow!.label);
                        await loadLastLocation();
                      }
                    },
                    child: const Text("Update Details"),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              "Upcoming Entries:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...upcoming.map(
              (w) => ListTile(
                title: Text(w.label),
                trailing: const Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Past Entries:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...past.map(
              (e) => ListTile(
                title: Text(e['label']!),
                trailing: Text(
                  e['status']!,
                  style: TextStyle(
                    color: e['status'] == 'Done' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

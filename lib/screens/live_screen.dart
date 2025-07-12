

// ************************WORKING code****************************************
import 'package:blo_tracker/models/live_entry_model.dart';
import 'package:blo_tracker/screens/upload_details_screen.dart';
import 'package:blo_tracker/services/tracking_manager.dart';
import 'package:blo_tracker/utils/time_window_utils.dart';
import 'package:blo_tracker/db/local_db.dart';
import 'package:flutter/material.dart';
import 'package:blo_tracker/services/location_uploader.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  List<LiveEntry> _allEntries = [];
  String? _lastLocationText;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final db = LocalDatabase.instance;
    final now = DateTime.now();
    final entries = await db.getEntriesForDate(now);
    print("📥 Loaded ${entries.length} entries for today");

    final lastSubmitted = entries.where((e) => e.isSubmitted).fold<LiveEntry?>(
      null,
      (prev, curr) {
        if (prev == null) return curr;
        return curr.timeSlot.isAfter(prev.timeSlot) ? curr : prev;
      },
    );

    String? locationText;

    if (lastSubmitted != null &&
        lastSubmitted.latitude != null &&
        lastSubmitted.longitude != null) {
      final lat = lastSubmitted.latitude!.toStringAsFixed(5);
      final lon = lastSubmitted.longitude!.toStringAsFixed(5);

      final time = TimeOfDay.fromDateTime(lastSubmitted.timeSlot);
      final formattedTime = time.format(context);

      final date = lastSubmitted.timeSlot;
      final weekday = _weekdayName(date.weekday);
      final formattedDate =
          "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ($weekday)";

      locationText = "$lat, $lon\nUpdated on: $formattedTime, $formattedDate";
    } else {
      locationText = "Not yet updated";
    }

    setState(() {
      _allEntries = entries;
      _lastLocationText = locationText;
    });
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String _weekdayName(int weekday) {
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeWindows = getTimeWindows(now);

    List<Widget> pastWidgets = [];
    List<Widget> upcomingWidgets = [];

    for (final window in timeWindows) {
      final existingEntry = _allEntries.firstWhere(
        (e) =>
            e.timeSlot.hour == window.start.hour &&
            e.timeSlot.minute == window.start.minute,
        orElse: () => LiveEntry(
          timeSlot: window.start,
          isSubmitted: false,
          isMissed: false,
        ),
      );

      final isSubmitted = existingEntry.isSubmitted;
      final isMissed = existingEntry.isMissed;

      if (isSubmitted || isMissed) {
        pastWidgets.add(_buildPastEntryTile(window, isSubmitted));
      } else if (now.isAfter(window.end)) {
        pastWidgets.add(_buildPastEntryTile(window, false)); // missed
      } else {
        final active = now.isAfter(window.start) && now.isBefore(window.end);
        upcomingWidgets.add(_buildUpcomingTile(window, active: active));
      }
    }

    return RefreshIndicator(
      onRefresh: _loadEntries,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.my_location, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last Location Sent:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _lastLocationText ?? "Not yet updated",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ElevatedButton(
          //   onPressed: () {
          //     TrackingManager.triggerOneTimeResume();
          //   },
          //   child: const Text("Trigger Now"),
          // ),

          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.location_searching),
            label: const Text("Test Upload Location"),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⏳ Uploading location (wait 2s)..."),
                ),
              );

              await Future.delayed(const Duration(seconds: 2));
              print("🟡 Test Button: Starting location upload...");

              try {
                await LocationUploader.sendLocationIfAllowed();
                await Future.delayed(const Duration(seconds: 2));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Test location uploaded")),
                );
                print("✅ Location upload successful");

                _loadEntries();
              } catch (e) {
                print("❌ Location upload failed: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Failed: $e")),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          if (upcomingWidgets.isNotEmpty) ...[
            Text(
              "Upcoming Entries",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...upcomingWidgets,
            const SizedBox(height: 20),
          ],
          Text("Past Entries", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...pastWidgets,
        ],
      ),
    );
  }

  Widget _buildUpcomingTile(TimeWindow window, {required bool active}) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: Text(window.label),
        subtitle: Text(active ? "You can update now" : "Scheduled for later"),
        trailing: active
            ? ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadDetailsScreen(window: window),
                    ),
                  );
                  if (result == true) {
                    _loadEntries();
                  }
                },
                child: const Text("Update Details"),
              )
            : null,
      ),
    );
  }

  Widget _buildPastEntryTile(TimeWindow window, bool isSubmitted) {
    return Card(
      child: ListTile(
        leading: Icon(
          isSubmitted ? Icons.check_circle : Icons.cancel,
          color: isSubmitted ? Colors.green : Colors.red,
        ),
        title: Text(window.label),
        subtitle: Text(isSubmitted ? "Details submitted" : "Missed slot"),
      ),
    );
  }
}




// import 'package:blo_tracker/models/live_entry_model.dart';
// import 'package:blo_tracker/screens/upload_details_screen.dart';
// import 'package:blo_tracker/services/tracking_manager.dart';
// import 'package:blo_tracker/utils/time_window_utils.dart';
// import 'package:blo_tracker/db/local_db.dart';
// import 'package:flutter/material.dart';
// import 'package:blo_tracker/services/location_uploader.dart';

// class LiveScreen extends StatefulWidget {
//   const LiveScreen({super.key});

//   @override
//   State<LiveScreen> createState() => _LiveScreenState();
// }

// class _LiveScreenState extends State<LiveScreen> {
//   List<LiveEntry> _allEntries = [];
//   String? _lastLocationText;
//   String _formatTime(DateTime dt) {
//     final hour = dt.hour.toString().padLeft(2, '0');
//     final minute = dt.minute.toString().padLeft(2, '0');
//     return "$hour:$minute";
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadEntries();
//   }

//   Future<void> _loadEntries() async {
//     final db = LocalDatabase.instance;
//     final now = DateTime.now();
//     final entries = await db.getEntriesForDate(now);
//     print("📥 Loaded ${entries.length} entries for today");

//     final lastSubmitted = entries.where((e) => e.isSubmitted).fold<LiveEntry?>(
//       null,
//       (prev, curr) {
//         if (prev == null) return curr;
//         return curr.timeSlot.isAfter(prev.timeSlot) ? curr : prev;
//       },
//     );

//     setState(() {
//       _allEntries = entries;
//       // _lastLocationText = lastSubmitted != null
//       // ? "${lastSubmitted.latitude?.toStringAsFixed(5)}, ${lastSubmitted.longitude?.toStringAsFixed(5)}"
//       // : "Not yet updated";
//       _lastLocationText = lastSubmitted != null
//           ? "${lastSubmitted.latitude?.toStringAsFixed(5)}, ${lastSubmitted.longitude?.toStringAsFixed(5)} at ${_formatTime(lastSubmitted.timeSlot)}"
//           : "Not yet updated";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final timeWindows = getTimeWindows(now);

//     List<Widget> pastWidgets = [];
//     List<Widget> upcomingWidgets = [];

//     for (final window in timeWindows) {
//       final existingEntry = _allEntries.firstWhere(
//         (e) =>
//             e.timeSlot.hour == window.start.hour &&
//             e.timeSlot.minute == window.start.minute,
//         orElse: () => LiveEntry(
//           timeSlot: window.start,
//           isSubmitted: false,
//           isMissed: false,
//         ),
//       );

//       final isSubmitted = existingEntry.isSubmitted;
//       final isMissed = existingEntry.isMissed;

//       if (isSubmitted || isMissed) {
//         pastWidgets.add(_buildPastEntryTile(window, isSubmitted));
//       } else if (now.isAfter(window.end)) {
//         pastWidgets.add(_buildPastEntryTile(window, false)); // missed
//       } else {
//         final active = now.isAfter(window.start) && now.isBefore(window.end);
//         upcomingWidgets.add(_buildUpcomingTile(window, active: active));
//       }
//     }

//     return RefreshIndicator(
//       onRefresh: _loadEntries,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.blue),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.my_location, color: Colors.blue),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     "Last Updated Location: $_lastLocationText",
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           // ElevatedButton(
//           //   onPressed: () {
//           //     // TrackingManager.triggerOneTimeResume();
//           //     TrackingManager.triggerOneTimeResume();
//           //   },
//           //   child: Text("Trigger Now"),
//           // ),
//           ElevatedButton(
//             onPressed: () {
//               TrackingManager.triggerOneTimeResume();
//             },
//             child: const Text("Trigger Now"),
//           ),

//           const SizedBox(height: 10),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.location_searching),
//             label: const Text("Test Upload Location"),
//             onPressed: () async {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text("⏳ Uploading location (wait 2s)..."),
//                 ),
//               );

//               await Future.delayed(
//                 const Duration(seconds: 2),
//               ); // ⏳ Wait before upload
//               print("🟡 Test Button: Starting location upload...");

//               try {
//                 await LocationUploader.sendLocationIfAllowed();
//                 await Future.delayed(
//                   const Duration(seconds: 2),
//                 ); // ⏳ Wait after upload

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("✅ Test location uploaded")),
//                 );
//                 print("✅ Location upload successful");

//                 _loadEntries(); // 🔄 Refresh the screen
//               } catch (e) {
//                 print("❌ Location upload failed: $e");
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(SnackBar(content: Text("❌ Failed: $e")));
//               }
//             },
//           ),
//           if (upcomingWidgets.isNotEmpty) ...[
//             Text(
//               "Upcoming Entries",
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 10),
//             ...upcomingWidgets,
//             const SizedBox(height: 20),
//           ],
//           Text("Past Entries", style: Theme.of(context).textTheme.titleMedium),
//           const SizedBox(height: 10),
//           ...pastWidgets,
//         ],
//       ),
//     );
//   }

//   Widget _buildUpcomingTile(TimeWindow window, {required bool active}) {
//     return Card(
//       elevation: 3,
//       child: ListTile(
//         leading: const Icon(Icons.access_time),
//         title: Text(window.label),
//         subtitle: Text(active ? "You can update now" : "Scheduled for later"),
//         trailing: active
//             ? ElevatedButton(
//                 onPressed: () async {
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => UploadDetailsScreen(window: window),
//                     ),
//                   );
//                   if (result == true) {
//                     _loadEntries();
//                   }
//                 },
//                 child: const Text("Update Details"),
//               )
//             : null,
//       ),
//     );
//   }

//   Widget _buildPastEntryTile(TimeWindow window, bool isSubmitted) {
//     return Card(
//       child: ListTile(
//         leading: Icon(
//           isSubmitted ? Icons.check_circle : Icons.cancel,
//           color: isSubmitted ? Colors.green : Colors.red,
//         ),
//         title: Text(window.label),
//         subtitle: Text(isSubmitted ? "Details submitted" : "Missed slot"),
//       ),
//     );
//   }
// }

// import 'package:blo_tracker/models/live_entry_model.dart';
// import 'package:blo_tracker/screens/upload_details_screen.dart';
// import 'package:blo_tracker/utils/time_window_utils.dart';
// import 'package:blo_tracker/db/local_db.dart';
// import 'package:flutter/material.dart';

// class LiveScreen extends StatefulWidget {
//   const LiveScreen({super.key});

//   @override
//   State<LiveScreen> createState() => _LiveScreenState();
// }

// class _LiveScreenState extends State<LiveScreen> {
//   List<LiveEntry> _allEntries = [];
//   String? _lastLocationText;

//   @override
//   void initState() {
//     super.initState();
//     _loadEntries();
//   }

//   Future<void> _loadEntries() async {
//     final db = LocalDatabase.instance;
//     final now = DateTime.now();
//     final entries = await db.getEntriesForDate(now);
//     print("📥 Loaded ${entries.length} entries for today");

//     // Get last submitted location
//     final lastSubmitted = entries
//         .where((e) => e.isSubmitted)
//         .fold<LiveEntry?>(null, (prev, curr) {
//       if (prev == null) return curr;
//       return curr.timeSlot.isAfter(prev.timeSlot) ? curr : prev;
//     });

//     setState(() {
//       _allEntries = entries;
//       _lastLocationText = lastSubmitted != null
//           ? "${lastSubmitted.latitude?.toStringAsFixed(5)}, ${lastSubmitted.longitude?.toStringAsFixed(5)}"
//           : "Not yet updated";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final timeWindows = getTimeWindows(now);

//     List<Widget> pastWidgets = [];
//     Widget? upcomingWidget;

//     for (final window in timeWindows) {
//       final existingEntry = _allEntries.firstWhere(
//         (e) =>
//             e.timeSlot.hour == window.start.hour &&
//             e.timeSlot.minute == window.start.minute,
//         orElse: () => LiveEntry(
//           timeSlot: window.start,
//           isSubmitted: false,
//           isMissed: false,
//         ),
//       );

//       final isSubmitted = existingEntry.isSubmitted;
//       final isMissed = existingEntry.isMissed;

//       if (isSubmitted || isMissed) {
//         pastWidgets.add(_buildPastEntryTile(window, isSubmitted));
//       } else if (now.isAfter(window.end)) {
//         pastWidgets.add(_buildPastEntryTile(window, false)); // missed
//       } else if (now.isAfter(window.start) && now.isBefore(window.end)) {
//         upcomingWidget = _buildUpcomingTile(window, active: true);
//         break;
//       } else if (now.isBefore(window.start) && upcomingWidget == null) {
//         upcomingWidget = _buildUpcomingTile(window, active: false);
//         break;
//       }
//     }

//     return RefreshIndicator(
//       onRefresh: _loadEntries,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.blue),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.my_location, color: Colors.blue),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     "Last Updated Location: $_lastLocationText",
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           if (upcomingWidget != null) ...[
//             Text(
//               "Upcoming Entry",
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 10),
//             upcomingWidget,
//             const SizedBox(height: 20),
//           ],
//           Text(
//             "Past Entries",
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 10),
//           ...pastWidgets,
//         ],
//       ),
//     );
//   }

//   Widget _buildUpcomingTile(TimeWindow window, {required bool active}) {
//     return Card(
//       elevation: 3,
//       child: ListTile(
//         leading: const Icon(Icons.access_time),
//         title: Text(window.label),
//         subtitle: Text(active ? "You can update now" : "Scheduled for later"),
//         trailing: active
//             ? ElevatedButton(
//                 onPressed: () async {
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => UploadDetailsScreen(window: window),
//                     ),
//                   );
//                   if (result == true) {
//                     _loadEntries();
//                   }
//                 },
//                 child: const Text("Update Details"),
//               )
//             : null,
//       ),
//     );
//   }

//   Widget _buildPastEntryTile(TimeWindow window, bool isSubmitted) {
//     return Card(
//       child: ListTile(
//         leading: Icon(
//           isSubmitted ? Icons.check_circle : Icons.cancel,
//           color: isSubmitted ? Colors.green : Colors.red,
//         ),
//         title: Text(window.label),
//         subtitle:
//             Text(isSubmitted ? "Details submitted" : "Missed slot"),
//       ),
//     );
//   }
// }

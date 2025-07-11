import 'package:blo_tracker/models/live_entry_model.dart';
import 'package:blo_tracker/screens/upload_details_screen.dart';
import 'package:blo_tracker/services/tracking_manager.dart';
import 'package:blo_tracker/utils/time_window_utils.dart';
import 'package:blo_tracker/db/local_db.dart';
import 'package:blo_tracker/widgets/custom_card.dart';
import 'package:blo_tracker/widgets/location_card.dart';
import 'package:blo_tracker/widgets/status_indicator.dart';
import 'package:flutter/material.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with TickerProviderStateMixin {
  List<LiveEntry> _allEntries = [];
  String? _lastLocationText;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadEntries();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    
    final db = LocalDatabase.instance;
    final now = DateTime.now();
    final entries = await db.getEntriesForDate(now);

    final lastSubmitted = entries.where((e) => e.isSubmitted).fold<LiveEntry?>(
      null,
      (prev, curr) {
        if (prev == null) return curr;
        return curr.timeSlot.isAfter(prev.timeSlot) ? curr : prev;
      },
    );

    setState(() {
      _allEntries = entries;
      _lastLocationText = lastSubmitted != null
          ? "${lastSubmitted.latitude?.toStringAsFixed(5)}, ${lastSubmitted.longitude?.toStringAsFixed(5)} at ${_formatTime(lastSubmitted.timeSlot)}"
          : null;
      _isLoading = false;
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final timeWindows = getTimeWindows(now);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> upcomingWidgets = [];
    List<Widget> pastWidgets = [];

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
        pastWidgets.add(_buildPastEntryTile(window, false));
      } else {
        final active = now.isAfter(window.start) && now.isBefore(window.end);
        upcomingWidgets.add(_buildUpcomingTile(window, active: active));
      }
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Location Status Card
            LocationCard(
              lastLocationText: _lastLocationText,
              onRefresh: _loadEntries,
            ),
            const SizedBox(height: 24),

            // Quick Action Button
            CustomCard(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              child: Column(
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 32,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Quick Actions",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        TrackingManager.triggerOneTimeResume();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🚀 Manual trigger initiated'),
                            backgroundColor: theme.colorScheme.secondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Trigger Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming Entries
            if (upcomingWidgets.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Upcoming Entries",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...upcomingWidgets.map((widget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget,
              )),
              const SizedBox(height: 24),
            ],

            // Past Entries
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Past Entries",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (pastWidgets.isEmpty)
              CustomCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No past entries yet",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your completed entries will appear here",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...pastWidgets.map((widget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTile(TimeWindow window, {required bool active}) {
    final theme = Theme.of(context);
    
    return CustomCard(
      color: active 
          ? theme.colorScheme.primary.withOpacity(0.1)
          : theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: active 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  active ? Icons.access_time : Icons.schedule,
                  color: active 
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      window.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusIndicator(
                      status: active ? StatusType.warning : StatusType.pending,
                      text: active ? "Available now" : "Scheduled for later",
                      showIcon: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.upload),
                label: const Text("Update Details"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPastEntryTile(TimeWindow window, bool isSubmitted) {
    final theme = Theme.of(context);
    
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSubmitted 
                  ? theme.colorScheme.secondary.withOpacity(0.1)
                  : theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSubmitted ? Icons.check_circle : Icons.cancel,
              color: isSubmitted 
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  window.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                StatusIndicator(
                  status: isSubmitted ? StatusType.success : StatusType.error,
                  text: isSubmitted ? "Details submitted" : "Missed slot",
                  showIcon: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
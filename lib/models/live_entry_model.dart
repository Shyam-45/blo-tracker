class LiveEntry {
  final DateTime timeSlot;
  final bool isSubmitted;
  final bool isMissed;
  final String? imagePath;
  final double? latitude;
  final double? longitude;

  LiveEntry({
    required this.timeSlot,
    required this.isSubmitted,
    required this.isMissed,
    this.imagePath,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'timeSlot': timeSlot.toIso8601String(),
      'isSubmitted': isSubmitted ? 1 : 0,
      'isMissed': isMissed ? 1 : 0,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LiveEntry.fromMap(Map<String, dynamic> map) {
    return LiveEntry(
      timeSlot: DateTime.parse(map['timeSlot']),
      isSubmitted: map['isSubmitted'] == 1,
      isMissed: map['isMissed'] == 1,
      imagePath: map['imagePath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

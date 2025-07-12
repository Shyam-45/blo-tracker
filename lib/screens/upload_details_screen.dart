import 'dart:io';
import 'package:blo_tracker/db/local_db.dart';
import 'package:blo_tracker/models/live_entry_model.dart';
import 'package:blo_tracker/services/upload_service.dart';
import 'package:blo_tracker/utils/location_utils.dart';
import 'package:blo_tracker/utils/time_window_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blo_tracker/providers/app_state_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:blo_tracker/providers/location_provider.dart';

class UploadDetailsScreen extends ConsumerStatefulWidget {
  final TimeWindow window;

  const UploadDetailsScreen({super.key, required this.window});

  @override
  ConsumerState<UploadDetailsScreen> createState() =>
      _UploadDetailsScreenState();
}

class _UploadDetailsScreenState extends ConsumerState<UploadDetailsScreen> {
  File? _image;
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;
  bool _submitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    final pos = await fetchCurrentLocation(context);
    if (pos != null) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Could not fetch location")),
      );
    }
    setState(() => _fetchingLocation = false);
  }

  Future<void> _submit() async {
    if (_image == null || _latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide image and location")),
      );
      return;
    }

    setState(() => _submitting = true);

    final token = ref.read(appStateProvider).authToken;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Authentication error. Please login again."),
        ),
      );
      setState(() => _submitting = false);
      return;
    }

    final entry = LiveEntry(
      timeSlot: widget.window.start,
      isSubmitted: true,
      isMissed: false,
      imagePath: _image!.path,
      latitude: _latitude,
      longitude: _longitude,
    );

    await LocalDatabase.instance.insertEntry(entry);

    final success = await UploadService.uploadEntry(
      imageFile: _image!,
      latitude: _latitude!,
      longitude: _longitude!,
      timeSlot: widget.window.start,
      token: token,
    );

    if (!success) {
      await LocalDatabase.instance.deleteEntry(widget.window.start);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed. Try again later.")),
      );
      setState(() => _submitting = false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Entry submitted successfully")),
    );
    // ref
    //     .read(lastLocationProvider.notifier)
    //     .updateLocation(_latitude!, _longitude!, DateTime.now());
    setState(() => _submitting = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text("Slot: ${widget.window.label}"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("No image selected"),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Location",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _latitude != null
                        ? "📍 $_latitude, $_longitude"
                        : "Location not fetched",
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _fetchingLocation ? null : _fetchLocation,
                    icon: const Icon(Icons.my_location),
                    label: Text(
                      _fetchingLocation ? "Fetching..." : "Fetch Location",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_image != null &&
                        _latitude != null &&
                        _longitude != null &&
                        !_fetchingLocation &&
                        !_submitting)
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:blo_tracker/db/local_db.dart';
// import 'package:blo_tracker/models/live_entry_model.dart';
// import 'package:blo_tracker/services/upload_service.dart';
// import 'package:blo_tracker/utils/location_utils.dart';
// import 'package:blo_tracker/utils/time_window_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:blo_tracker/providers/app_state_provider.dart';
// import 'package:intl/intl.dart';

// class UploadDetailsScreen extends ConsumerStatefulWidget {
//   final TimeWindow window;

//   const UploadDetailsScreen({super.key, required this.window});

//   @override
//   ConsumerState<UploadDetailsScreen> createState() =>
//       _UploadDetailsScreenState();
// }

// class _UploadDetailsScreenState extends ConsumerState<UploadDetailsScreen> {
//   File? _image;
//   double? _latitude;
//   double? _longitude;
//   bool _loading = false;

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 70);
//     if (picked != null) {
//       setState(() {
//         _image = File(picked.path);
//       });
//     }
//   }

//   Future<void> _fetchLocation() async {
//     setState(() => _loading = true);
//     final pos = await fetchCurrentLocation(context);
//     if (pos != null) {
//       setState(() {
//         _latitude = pos.latitude;
//         _longitude = pos.longitude;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Could not fetch location")),
//       );
//     }
//     setState(() => _loading = false);
//   }

//   Future<void> _submit() async {
//     if (_image == null || _latitude == null || _longitude == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please provide image and location")),
//       );
//       return;
//     }

//     final token = ref.read(appStateProvider).authToken;
//     if (token == null) {
//       print("🚫 No token found, cannot upload.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Authentication error. Please login again."),
//         ),
//       );
//       return;
//     }

//     final entry = LiveEntry(
//       timeSlot: widget.window.start,
//       isSubmitted: true,
//       isMissed: false,
//       imagePath: _image!.path,
//       latitude: _latitude,
//       longitude: _longitude,
//     );

//     print("📥 Saving to local DB...");
//     await LocalDatabase.instance.insertEntry(entry);

//     print("📡 Uploading to backend...");
//     final success = await UploadService.uploadEntry(
//       imageFile: _image!,
//       latitude: _latitude!,
//       longitude: _longitude!,
//       timeSlot: widget.window.start,
//       token: token,
//     );

//     if (!success) {
//       print("❌ Backend upload failed. Cleaning local entry.");
//       await LocalDatabase.instance.deleteEntry(widget.window.start);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Upload failed. Try again later.")),
//       );
//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("✅ Entry submitted successfully")),
//     );
//     Navigator.pop(context, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formatted = DateFormat.jm().format(widget.window.start);
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Details")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border.all(color: Colors.blueAccent),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.access_time, color: Colors.blue),
//                   const SizedBox(width: 10),
//                   Text("Slot: ${widget.window.label}"),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_image != null)
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.green),
//                   borderRadius: BorderRadius.circular(12),
//                   image: DecorationImage(
//                     image: FileImage(_image!),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 height: 150,
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Text("No image selected"),
//               ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Camera"),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: const Icon(Icons.photo),
//                   label: const Text("Gallery"),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.orange),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Location",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _latitude != null
//                         ? "📍 $_latitude, $_longitude"
//                         : "Location not fetched",
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     onPressed: _loading ? null : _fetchLocation,
//                     icon: const Icon(Icons.my_location),
//                     label: Text(_loading ? "Fetching..." : "Fetch Location"),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed:
//                     (_image != null &&
//                         _latitude != null &&
//                         _longitude != null &&
//                         !_loading)
//                     ? _submit
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Colors.green,
//                 ),
//                 child: const Text("Submit Details"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';

// import 'package:blo_tracker/utils/location_utils.dart';
// import 'package:blo_tracker/db/local_db.dart';
// import 'package:blo_tracker/models/live_entry_model.dart';
// import 'package:blo_tracker/utils/time_window_utils.dart';
// import 'package:blo_tracker/services/upload_service.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// class UploadDetailsScreen extends StatefulWidget {
//   final TimeWindow window;

//   const UploadDetailsScreen({super.key, required this.window});

//   @override
//   State<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
// }

// class _UploadDetailsScreenState extends State<UploadDetailsScreen> {
//   File? _image;
//   double? _latitude;
//   double? _longitude;
//   bool _loading = false;

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 70);
//     if (picked != null) {
//       setState(() {
//         _image = File(picked.path);
//       });
//     }
//   }

//   Future<void> _fetchLocation() async {
//     setState(() => _loading = true);
//     final pos = await fetchCurrentLocation(context);
//     if (pos != null) {
//       setState(() {
//         _latitude = pos.latitude;
//         _longitude = pos.longitude;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Could not fetch location")),
//       );
//     }
//     setState(() => _loading = false);
//   }

//   Future<void> _submit() async {
//     if (_image == null || _latitude == null || _longitude == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please provide image and location")),
//       );
//       return;
//     }

//     final entry = LiveEntry(
//       timeSlot: widget.window.start,
//       isSubmitted: true,
//       isMissed: false,
//       imagePath: _image!.path,
//       latitude: _latitude,
//       longitude: _longitude,
//     );

//     print("📥 Saving to local DB...");
//     await LocalDatabase.instance.insertEntry(entry);

//     print("📡 Uploading to backend...");
//     final success = await UploadService.uploadEntry(entry);

//     if (!success) {
//       print("❌ Upload failed. Rolling back local insert.");
//       await LocalDatabase.instance.deleteEntry(entry.timeSlot);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Upload failed. Try again.")),
//       );
//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("✅ Entry submitted successfully")),
//     );
//     Navigator.pop(context, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Details")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border.all(color: Colors.blueAccent),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.access_time, color: Colors.blue),
//                   const SizedBox(width: 10),
//                   Text("Slot: ${widget.window.label}"),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Image preview
//             if (_image != null)
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.green),
//                   borderRadius: BorderRadius.circular(12),
//                   image: DecorationImage(
//                     image: FileImage(_image!),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 height: 150,
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Text("No image selected"),
//               ),

//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Camera"),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: const Icon(Icons.photo),
//                   label: const Text("Gallery"),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.orange),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Location",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _latitude != null
//                         ? "📍 $_latitude, $_longitude"
//                         : "Location not fetched",
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     onPressed: _loading ? null : _fetchLocation,
//                     icon: const Icon(Icons.my_location),
//                     label: Text(_loading ? "Fetching..." : "Fetch Location"),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _submit,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Colors.green,
//                 ),
//                 child: const Text("Submit Details"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

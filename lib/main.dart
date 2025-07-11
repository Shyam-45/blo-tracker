import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:blo_tracker/screens/splash_screen.dart';
import 'package:blo_tracker/screens/login_screen.dart';
import 'package:blo_tracker/screens/home_screen.dart';
import 'package:blo_tracker/screens/permission_required_screen.dart';
import 'package:blo_tracker/screens/live_screen.dart';
import 'package:blo_tracker/services/location_uploader.dart';
import 'package:blo_tracker/theme/app_theme.dart';

// Constants for task names
const String periodicTaskName = 'location_upload_task';
const String oneTimeTaskName = 'resume_location_task';
const String testTaskName = 'testTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print("📦 Workmanager triggered: $taskName");

    if (taskName == periodicTaskName || taskName == oneTimeTaskName) {
      print("📍 LocationUploader.sendLocationIfAllowed() called");
      await LocationUploader.sendLocationIfAllowed();
    } else if (taskName == testTaskName) {
      print("🚀 Test task executed!");
    }

    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLO Survey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
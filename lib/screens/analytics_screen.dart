import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('📊 AnalyticsScreen loaded');
    return const Center(
      child: Text("Analytics for Past 7 Days"),
    );
  }
}

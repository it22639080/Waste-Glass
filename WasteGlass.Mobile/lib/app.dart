import 'package:flutter/material.dart';

import 'core/constants/app_theme.dart';
import 'screens/scan_collect_screen.dart';
import 'screens/trip_report_screen.dart';
import 'screens/trip_sequence_screen.dart';
import 'widgets/page_entrance.dart';

class WasteGlassApp extends StatelessWidget {
  const WasteGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Glass Collection',
      theme: AppTheme.light,
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TripSequenceScreen(
        onStartCollection: () => setState(() => _index = 1),
        onViewReport: () => setState(() => _index = 2),
      ),
      ScanCollectScreen(
        onBack: () => setState(() => _index = 0),
        onViewReport: () => setState(() => _index = 2),
      ),
      TripReportScreen(onBackToSequence: () => setState(() => _index = 0)),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: PageEntrance(
            key: ValueKey(_index),
            child: screens[_index],
          ),
        ),
      ),
    );
  }
}

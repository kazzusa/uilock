import 'dart:async';

import 'package:flutter/material.dart';

import 'productivity_menu_screen.dart';

/// Screen 1 of 2 in productivity mode: the minimal home screen.
/// Shows the clock, the date, a settings icon and the Menu button.
class ProductivityHomeScreen extends StatefulWidget {
  const ProductivityHomeScreen({super.key});

  @override
  State<ProductivityHomeScreen> createState() =>
      _ProductivityHomeScreenState();
}

class _ProductivityHomeScreenState extends State<ProductivityHomeScreen> {
  static const _accent = Color(0xFF5A5BD0);

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // Check every second, but redraw only when the minute or day changes.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (now.minute != _now.minute || now.day != _now.day) {
        setState(() => _now = now);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop the timer when the screen is closed
    super.dispose();
  }

  /// 24-hour format without a leading zero on the hour: 5:00, 14:00
  String get _timeText =>
      '${_now.hour}:${_now.minute.toString().padLeft(2, '0')}';

  /// 1st, 2nd, 3rd, 4th ... 11th, 12th, 13th ... 21st
  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  /// Example: Wednesday, 3rd June
  String get _dateText =>
      '${_weekdays[_now.weekday - 1]}, ${_ordinal(_now.day)} ${_months[_now.month - 1]}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Clock
              Text(
                _timeText,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                _dateText,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),

              // The free space in the middle is where the 3 shortcut apps
              // will go in a later stage.
              const Spacer(flex: 5),

              // Bottom row: settings icon (left) and Menu button (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // TODO: decide what the settings icon opens.
                    },
                  ),
                  Material(
                    color: _accent,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductivityMenuScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 11,
                        ),
                        child: Text(
                          'Menu',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
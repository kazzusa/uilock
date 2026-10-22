import 'package:flutter/material.dart';

/// One saved schedule (session). This is what the home screen keeps in its list.
class Schedule {
  /// The name of the saved session, e.g. "Study time".
  String name;

  TimeOfDay start;
  TimeOfDay end;

  /// 0 = Sunday, 1 = Monday, ... 6 = Saturday
  Set<int> days;

  /// Controls the status bar on the saved card.
  /// true  = green bar (schedule is active)
  /// false = red bar (schedule is disabled)
  bool isEnabled;

  Schedule({
    required this.name,
    required this.start,
    required this.end,
    required this.days,
    this.isEnabled = true,
  });
}
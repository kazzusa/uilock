import 'package:flutter/material.dart';

/// One saved schedule. This is what the home screen keeps in its list.
class Schedule {
  TimeOfDay start;
  TimeOfDay end;

  /// 0 = Sunday, 1 = Monday, ... 6 = Saturday
  Set<int> days;

  /// Controls the status bar on the saved card.
  /// true  = green bar (schedule is active)
  /// false = red bar (schedule is disabled)
  /// Not final on purpose, so it can be changed later:
  ///   setState(() => schedule.isEnabled = false);
  bool isEnabled;

  Schedule({
    required this.start,
    required this.end,
    required this.days,
    this.isEnabled = true,
  });
}

import 'package:flutter/material.dart';

import '../models/schedule.dart';

/// The card shown on the home screen after a schedule is saved.
class SavedScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const SavedScheduleCard({super.key, required this.schedule});

  static const _letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static const _cardColor = Color(0xFF1A1A1A);
  static const _accent = Color(0xFF5A5BD0); // selected day color
  static const _dayOff = Color(0xFF333333); // unselected day color
  static const _enabledColor = Color(0xFF4CD964); // green bar
  static const _disabledColor = Color(0xFFE53935); // red bar

  /// 24-hour format without a leading zero on the hour: 5:00, 14:00
  String _format(TimeOfDay t) =>
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: _cardColor,
        child: Stack(
          children: [
            // Main content
            Padding(
              // Right padding leaves room for the status bar.
              padding: const EdgeInsets.fromLTRB(18, 14, 23, 14),
              child: Row(
                children: [
                  _TimeBlock(
                    label: 'Time Start',
                    value: _format(schedule.start),
                  ),
                  const SizedBox(width: 20),
                  _TimeBlock(
                    label: 'Time End',
                    value: _format(schedule.end),
                  ),
                  const Spacer(),
                  ...List.generate(7, (i) {
                    final selected = schedule.days.contains(i);
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        _letters[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selected ? _accent : _dayOff,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Status bar on the right edge
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 5,
                color: schedule.isEnabled ? _enabledColor : _disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small label with a large time under it.
class _TimeBlock extends StatelessWidget {
  final String label;
  final String value;

  const _TimeBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
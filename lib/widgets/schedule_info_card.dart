import 'package:flutter/material.dart';

import '../models/schedule.dart';
import 'schedule_card.dart';

/// Opens the information panel for one saved schedule.
/// [onChanged] is called every time something in the schedule changes,
/// so the screen behind the panel can redraw its card.
Future<void> showScheduleInfo(
  BuildContext context,
  Schedule schedule, {
  VoidCallback? onChanged,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ScheduleInfoCard(schedule: schedule, onChanged: onChanged),
  );
}

class ScheduleInfoCard extends StatefulWidget {
  final Schedule schedule;
  final VoidCallback? onChanged;

  const ScheduleInfoCard({super.key, required this.schedule, this.onChanged});

  @override
  State<ScheduleInfoCard> createState() => _ScheduleInfoCardState();
}

class _ScheduleInfoCardState extends State<ScheduleInfoCard> {
  static const _panel = Color(0xFFD9D9D9);
  static const _boxDark = Color(0xFF303030);
  static const _accent = Color(0xFF5A5BD0);
  static const _enabledColor = Color(0xFF4CD964);
  static const _disabledColor = Color(0xFFE53935);
  static const _letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  /// 24-hour format without a leading zero on the hour: 5:00, 14:00
  String _format(TimeOfDay t) =>
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

  void _toggleActive() {
    // 1. Flip the status. The dialog redraws (setState).
    setState(() {
      widget.schedule.isEnabled = !widget.schedule.isEnabled;
    });
    // 2. Tell the main screen, so the card behind redraws its status bar.
    widget.onChanged?.call();
  }

  Future<void> _editSession() async {
    final s = widget.schedule;

    // Open the same card as "add", but with the current values filled in.
    final result = await showScheduleCard(
      context,
      initial: ScheduleResult(
        name: s.name,
        start: s.start,
        end: s.end,
        days: s.days,
      ),
    );
    if (result == null || !mounted) return; // Back was pressed

    setState(() {
      s.name = result.name;
      s.start = result.start;
      s.end = result.end;
      s.days = result.days;
    });
    widget.onChanged?.call(); // redraw the card on the main screen
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.schedule;

    return Dialog(
      backgroundColor: _panel,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Session name
            SizedBox(
              width: double.infinity,
              child: Text(
                s.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time start and time end
            Row(
              children: [
                Expanded(
                  child: _InfoTime(label: 'Time Start', value: _format(s.start)),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _InfoTime(label: 'Time End', value: _format(s.end)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final selected = s.days.contains(i);
                return Text(
                  _letters[i],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selected ? _accent : _boxDark,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PillButton(
                      label: 'Edit Session',
                      color: _accent,
                      onPressed: _editSession,
                    ),
                    const SizedBox(height: 10),
                    _PillButton(
                      label: s.isEnabled ? 'Active' : 'Disabled',
                      color: s.isEnabled ? _enabledColor : _disabledColor,
                      onPressed: _toggleActive,
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A small label above a dark rounded box that shows the time.
class _InfoTime extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTime({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF303030),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// A pill-shaped button with a ripple.
class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
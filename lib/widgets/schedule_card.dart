import 'package:flutter/material.dart';

/// The data the card returns when the user presses Save.
class ScheduleResult {
  final TimeOfDay start;
  final TimeOfDay end;

  /// 0 = Sunday, 1 = Monday, ... 6 = Saturday
  final Set<int> days;

  const ScheduleResult({
    required this.start,
    required this.end,
    required this.days,
  });
}

/// Opens the card. Returns a ScheduleResult on Save, or null on Cancel
/// or when the user taps outside the card.
Future<ScheduleResult?> showScheduleCard(
  BuildContext context, {
  ScheduleResult? initial,
}) {
  return showDialog<ScheduleResult>(
    context: context,
    builder: (_) => ScheduleCard(initial: initial),
  );
}

class ScheduleCard extends StatefulWidget {
  final ScheduleResult? initial;

  const ScheduleCard({super.key, this.initial});

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  late TimeOfDay _start;
  late TimeOfDay _end;
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    _start = widget.initial?.start ?? const TimeOfDay(hour: 9, minute: 0);
    _end = widget.initial?.end ?? const TimeOfDay(hour: 17, minute: 0);
    _days = {...?widget.initial?.days};
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (_days.contains(day)) {
        _days.remove(day);
      } else {
        _days.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Add New Schedule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // Start and end time
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: 'Time Start',
                    time: _start,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeTile(
                    label: 'Time End',
                    time: _end,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Days
            const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DaySelector(selectedDays: _days, onToggle: _toggleDay),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  // Disabled until at least one day is chosen.
                  onPressed: _days.isEmpty
                      ? null
                      : () => Navigator.pop(
                          context,
                          ScheduleResult(start: _start, end: _end, days: _days),
                        ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable box that shows a label and a time.
class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        Material(
          color: const Color(0xFF303030),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  time.format(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The row of S M T W T F S circles. Multiple days can be selected.
class DaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<int> onToggle;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onToggle,
  });

  static const _letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final selected = selectedDays.contains(i);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onToggle(i),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? const Color.fromARGB(255, 119, 5, 250)
                      : const Color(0xFF616161),
                ),
                child: Text(_letters[i]),
              ),
            ),
          ),
        );
      }),
    );
  }
}

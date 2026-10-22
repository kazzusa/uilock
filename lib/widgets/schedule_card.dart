import 'package:flutter/material.dart';

/// The data the card returns when the user presses Save.
class ScheduleResult {
  final String name;
  final TimeOfDay start;
  final TimeOfDay end;

  /// 0 = Sunday, 1 = Monday, ... 6 = Saturday
  final Set<int> days;

  const ScheduleResult({
    required this.name,
    required this.start,
    required this.end,
    required this.days,
  });
}

/// Opens the card. Returns a ScheduleResult on Save, or null on Back
/// or when the user taps outside the card.
/// Pass [initial] to fill the card with existing values (editing).
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
  late final TextEditingController _nameController;
  TimeOfDay? _start; // null = no time chosen yet
  TimeOfDay? _end;
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _start = widget.initial?.start;
    _end = widget.initial?.end;
    _days = {...?widget.initial?.days}; // a copy, so Back leaves the original
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Save is enabled only when everything is filled in.
  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _start != null &&
      _end != null &&
      _days.isNotEmpty;

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _start : _end) ?? TimeOfDay.now(),
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

  void _save() {
    Navigator.pop(
      context,
      ScheduleResult(
        name: _nameController.text.trim(),
        start: _start!, // safe: _canSave checked that they are not null
        end: _end!,
        days: _days,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFD9D9D9),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // Scrollable, so the card never overflows when the keyboard opens.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title (full width, so textAlign can center it)
            SizedBox(
              width: double.infinity,
              child: Text(
                widget.initial == null ? 'Add New Schedule' : 'Edit Session',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Session name
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              maxLength: 20,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onChanged: (_) => setState(() {}), // refreshes the Save button
              decoration: InputDecoration(
                hintText: 'Session name',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                counterText: '', // hides the "0/20" counter
                filled: true,
                fillColor: const Color(0xFF303030),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                const SizedBox(width: 24),
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
            const Text(
              'Repeat',
              style: TextStyle(fontSize: 12, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 10),
            DaySelector(selectedDays: _days, onToggle: _toggleDay),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Back', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: _canSave ? _save : null, // null = disabled
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.black38,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A dark rounded box. Shows its name until a time is picked,
/// then shows the picked time.
class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = time;
    final isEmpty = t == null;

    return Material(
      color: const Color(0xFF303030),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Center(
            child: Text(
              isEmpty ? label : t.format(context),
              style: TextStyle(
                color: isEmpty ? Colors.grey.shade500 : Colors.white,
                fontSize: isEmpty ? 14 : 18,
                fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The row of S M T W T F S letters. Multiple days can be selected.
/// Dark grey when not picked, blue when picked.
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
          behavior: HitTestBehavior.opaque, // the whole box is tappable
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
                  color: selected ? const Color.fromARGB(255, 119, 5, 250) : const Color(0xFF616161),
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
import 'package:flutter/material.dart';
import 'package:uilock/models/schedule.dart';
import 'package:uilock/widgets/circle_button.dart';
import 'package:uilock/widgets/saved_schedule_card.dart';
import 'package:uilock/widgets/schedule_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'UILock'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Every saved schedule lives in this list.
  final List<Schedule> _schedules = [];

  Future<void> _addSchedule() async {
    final result = await showScheduleCard(context);
    if (result == null || !mounted) return; // Cancel was pressed

    setState(() {
      _schedules.add(
        Schedule(
          start: result.start,
          end: result.end,
          days: result.days,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 29, 30, 31),
        title: Text(
          widget.title,
          style: TextStyle(color: const Color.fromARGB(255, 119, 5, 250)),
        ),
      ),
      // The add button is the LAST item of the list, so it moves down
      // by itself every time a card is added above it.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final schedule in _schedules)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SavedScheduleCard(schedule: schedule),
            ),
          // Center is needed: a ListView forces its children to full width,
          // and Center lets the button keep its own circle size.
          Center(
            child: CircleButton(
              onPressed: _addSchedule,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 44, 45, 47),
    );
  }
}
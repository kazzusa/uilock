import 'package:flutter/material.dart';
import 'package:uilock/widgets/circle_button.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            CircleButton(
              child: Icon(Icons.add),
              onPressed: () async {
                final result = await showScheduleCard(context);

                if (result != null) {
                  // The user pressed Save. Use the data here.
                  print(result.start.format(context)); // e.g. 9:00 AM
                  print(result.end.format(context)); // e.g. 5:00 PM
                  print(result.days); // e.g. {1, 3, 5}
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 44, 45, 47),
    );
  }
}

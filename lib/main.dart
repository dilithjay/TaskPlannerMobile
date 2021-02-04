import 'package:flutter/material.dart';
import 'task_list.dart';
// import 'package:intl/intl.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimePlanner',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: TaskList(),
    );
  }
}

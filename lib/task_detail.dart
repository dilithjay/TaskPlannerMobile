import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'task.dart';
import 'database_helper.dart';

class TaskDetail extends StatefulWidget {
  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  DateTime _selectedDate = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  final _myController = TextEditingController();
  List<String> daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  DatabaseHelper databaseHelper = DatabaseHelper();
  bool daily = false;

  @override
  Widget build(BuildContext context) {
    _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate, // Refer step 1
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 5),
      );
      if (picked != null && picked != _selectedDate)
        setState(() {
          _selectedDate = picked;
        });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add task"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: moveToLastScreen,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: TextField(
                controller: _myController,
                decoration: InputDecoration(
                    labelText: 'Task',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Row(
              children: [
                Text("Daily:"),
                Checkbox(
                  value: daily,
                  onChanged: (bool val) {
                    setState(() {
                      daily = val;
                    });
                  },
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () => daily ? () {} : _selectDate(context),
                    child: Text(
                      'Select date',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    color: daily ? Colors.grey : Colors.greenAccent,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(daysOfWeek[_selectedDate.weekday - 1],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(formatter.format(_selectedDate)),
                ),
              ],
              mainAxisSize: MainAxisSize.max,
            ),
            RaisedButton(
              onPressed: () {
                Future<int> result;
                if (daily) {
                  result =
                      databaseHelper.insertDailyTask(_myController.text, 0);
                } else {
                  Task task = new Task(
                      _myController.text,
                      0,
                      daysOfWeek[_selectedDate.weekday - 1] +
                          ' ' +
                          formatter.format(_selectedDate));
                  result = databaseHelper.insertTask(task);
                }
                result.then((res) {});
                _myController.clear();
              },
              child: Text(
                'Save Task',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              color: Colors.greenAccent,
            )
          ],
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}

import 'package:flutter/material.dart';
import 'package:time_planner/task_detail.dart';
import 'dart:async';
import 'task.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Map<String, dynamic> tasksInDate;
  int count = 0;
  ListView cardList;
  Map<String, bool> checked = Map();
  //int _selectedIndex = 0;
  Set<String> dateList = {};

  /*void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    if (tasksInDate == null) {
      tasksInDate = Map();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      body: getFutureBuilder(),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToDetail,
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
      /*bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.view_week), label: "week"),
          BottomNavigationBarItem(icon: Icon(Icons.view_day), label: "day"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        onTap: _onItemTapped,
      ),*/
    );
  }

  Widget getFutureBuilder() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseHelper.getTaskMapList(),
      initialData: List(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: getDateCount(snapshot.data),
                itemBuilder: (_, int position) {
                  final String date = dateList.toList()[position];
                  List<Map<String, dynamic>> lst = [];
                  for (var i in snapshot.data) {
                    if (i['date'] == date) {
                      lst.add(i);
                      checked[i['id'].toString()] =
                          (int.parse(i['checked']) == 1);
                    }
                  }

                  return Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Text(
                                  date.substring(0, 3),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("  " + date.substring(3))
                              ],
                            ),
                          ),
                          for (var i in lst)
                            Dismissible(
                              child: CheckboxListTile(
                                value: checked[i['id'].toString()],
                                onChanged: (bool val) {
                                  Future<int> result = databaseHelper
                                      .changeCheckTask(i['id'], val ? 1 : 0);
                                  result.then((res) {});

                                  Future<List<Map<String, dynamic>>> mp =
                                      databaseHelper.getTaskMapList();
                                  mp.then((res) {});
                                  setState(() {
                                    checked[i['id'].toString()] = val;
                                  });
                                },
                                title: Text(i['task']),
                              ),
                              background: Container(
                                color: Colors.red,
                              ),
                              key: UniqueKey(),
                              onDismissed: (DismissDirection dd) {
                                databaseHelper.deleteTask(i['id']);
                                setState(() {});
                              },
                            )
                        ],
                      ));
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  int getDateCount(List<Map<String, dynamic>> data) {
    Set<String> dl = Set();
    for (var i in data) {
      if (!dl.contains(i['date'])) dl.add(i['date']);
    }
    this.dateList = dl;
    return dateList.length;
  }

  void navigateToDetail() async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TaskDetail();
    }));
    if (result) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      var taskMap = databaseHelper.getTaskMapList();
      taskMap.then((tasklist) {
        Map<String, dynamic> tid = new Map();
        for (var i in tasklist) {
          if (tid.containsKey(i['date']))
            tid[i['date']].add(i);
          else
            tid[i['date']] = [i];
        }

        setState(() {
          this.tasksInDate = tid;
        });
      });
    });
  }
}

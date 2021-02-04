import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_planner/task_detail.dart';
import 'dart:async';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String _lastUpdate;
  Map<String, dynamic> tasksInDate;
  int count = 0;
  ListView cardList;
  Map<String, bool> checked = Map();
  Map<String, bool> dailyChecked = Map();
  List<dynamic> dailyTasks = [];
  int _selectedIndex = 0;
  Set<String> dateList = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tasksInDate == null) {
      tasksInDate = Map();
      updateDailyListView();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      body: _selectedIndex == 0 ? getFutureBuilder() : getDailyFutureBuilder(),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToDetail,
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.all_out), label: "General"),
          BottomNavigationBarItem(icon: Icon(Icons.view_day), label: "Daily"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        onTap: _onItemTapped,
      ),
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
                  final String date =
                      dateList.toList().reversed.toList()[position];
                  List<Map<String, dynamic>> lst = [];
                  for (var i in snapshot.data) {
                    if (i['date'] == date) {
                      lst.add(i);
                      checked[i['id'].toString()] = (i['checked'] == 1);
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
                                  date == null ? "Mon" : date.substring(0, 3),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("  " +
                                    (date == null
                                        ? '0.0.0'
                                        : date.substring(3)))
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

  Widget getDailyFutureBuilder() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseHelper.getDailyTaskMapList(),
      initialData: List(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, int position) {
                  List<Map<String, dynamic>> lst = [];
                  for (var i in snapshot.data) {
                    lst.add(i);
                    dailyChecked[i['id'].toString()] = (i['checked'] == 1);
                  }

                  return Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: Column(
                        children: [
                          for (var i in lst)
                            Dismissible(
                              child: CheckboxListTile(
                                value: dailyChecked[i['id'].toString()],
                                onChanged: (bool val) {
                                  Future<int> result =
                                      databaseHelper.changeCheckDailyTask(
                                          i['id'], val ? 1 : 0);
                                  result.then((res) {});

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
                                databaseHelper.deleteDailyTask(i['id']);
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

  void resetDailyTasks() {
    final fPrefs = SharedPreferences.getInstance();
    fPrefs.then((prefs) {
      setState(() {
        String day = prefs.getString('day');
        if (day == null) {
          _lastUpdate = formatter.format(DateTime.now());
          prefs.setString('day', _lastUpdate);
        } else {
          _lastUpdate = day;
          if (DateTime.now().isAfter(formatter.parse(_lastUpdate))) {
            Future<int> res = databaseHelper.resetDailyTasks();
            res.then((result) {});
          }
        }
      });
    });
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

  void updateDailyListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      var taskMap = databaseHelper.getDailyTaskMapList();
      taskMap.then((tasklist) {
        setState(() {
          this.dailyTasks = tasklist;
        });
      });
    });
  }
}

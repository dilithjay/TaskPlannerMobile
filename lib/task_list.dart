import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_planner/task_detail.dart';
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
  List<Map<String, dynamic>> todayTasks = [];
  List<dynamic> dailyTasks = [];
  int _selectedIndex = 0;
  Set<String> dateList = {};
  Set<String> historyDateList = {};
  int deletedIDDaily;
  int deletedIDHistory;
  int deletedID;

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
      resetDailyTasks();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Task Planner"),
      ),
      body: _selectedIndex == 0
          ? getFutureBuilder()
          : _selectedIndex == 1
              ? getDailyFutureBuilder()
              : getHistoryFutureBuilder(),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToDetail,
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.all_out), label: "General"),
          BottomNavigationBarItem(icon: Icon(Icons.view_day), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
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
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  List<String> dates = dateList.toList();
                  dates.sort();
                  final String date = dates[position];
                  List<Map<String, dynamic>> lst = [];
                  for (var i in snapshot.data) {
                    if (i['date'] == date) {
                      lst.add(i);
                      checked[i['id'].toString()] = (i['checked'] == 1);
                    }
                  }
                  if (date != null &&
                      date.substring(4) == formatter.format(DateTime.now())) {
                    todayTasks = lst;
                  } else if (date == null) todayTasks = [];

                  return Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                date == null
                                    ? SizedBox.shrink()
                                    : Text(
                                        date.substring(0, 3),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                date == null
                                    ? SizedBox.shrink()
                                    : Text("  " + (date.substring(3)))
                              ],
                            ),
                          ),
                          for (var i in lst)
                            deletedID != i['id']
                                ? Dismissible(
                                    child: CheckboxListTile(
                                      value: checked[i['id'].toString()],
                                      onChanged: (bool val) {
                                        Future<int> result =
                                            databaseHelper.changeCheckTask(
                                                i['id'], val ? 1 : 0);
                                        result.then((res) {});

                                        setState(() {
                                          checked[i['id'].toString()] = val;
                                        });
                                      },
                                      title: Text(i['task']),
                                    ),
                                    background: Container(
                                      color: Colors.greenAccent[400],
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Icon(Icons.done),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.red,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Icon(Icons.delete_outline),
                                    ),
                                    key: UniqueKey(),
                                    onDismissed: (DismissDirection dd) {
                                      var res =
                                          databaseHelper.deleteTask(i['id']);
                                      res.then((result) {
                                        todayTasks.remove(i);
                                        if (dd == DismissDirection.startToEnd) {
                                          var res = databaseHelper
                                              .insertHistoryTask(i);
                                          res.then((result) {
                                            setState(() {
                                              deletedID = i['id'];
                                            });
                                          });
                                        } else {
                                          setState(() {
                                            deletedID = i['id'];
                                          });
                                        }
                                      });
                                    },
                                  )
                                : resetDeletedID()
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

  SizedBox resetDeletedID() {
    deletedID = null;
    return SizedBox.shrink();
  }

  int getDateCount(List<Map<String, dynamic>> data) {
    Set<String> dl = Set();
    for (var i in data) {
      if (!dl.contains(i['date'])) dl.add(i['date']);
    }
    this.dateList = dl;
    return dateList.length;
  }

  Widget getHistoryFutureBuilder() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseHelper.getHistoryMapList(),
      initialData: List(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: getDateCountHistory(snapshot.data),
                itemBuilder: (_, int position) {
                  List<String> dates = historyDateList.toList();
                  dates.sort();
                  final String date = dates[position];
                  List<Map<String, dynamic>> lst = [];
                  for (var i in snapshot.data) {
                    if (i['date'] == date) {
                      lst.add(i);
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
                                date == null
                                    ? SizedBox.shrink()
                                    : Text(
                                        date.substring(0, 3),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                date == null
                                    ? SizedBox.shrink()
                                    : Text("  " + (date.substring(3)))
                              ],
                            ),
                          ),
                          for (var i in lst)
                            deletedIDHistory != i['id']
                                ? Dismissible(
                                    direction: DismissDirection.endToStart,
                                    child: CheckboxListTile(
                                      value: i['checked'] == 1,
                                      onChanged: (bool val) {},
                                      title: Text(i['task']),
                                      activeColor: Colors.grey,
                                    ),
                                    background: Container(
                                      color: Colors.red,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Icon(Icons.delete_outline),
                                    ),
                                    key: UniqueKey(),
                                    onDismissed: (DismissDirection dd) {
                                      var res = databaseHelper
                                          .deleteHistoryTask(i['id']);
                                      res.then((result) {
                                        setState(() {
                                          deletedIDHistory = i['id'];
                                        });
                                      });
                                    },
                                  )
                                : resetDeletedIDHistory()
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

  SizedBox resetDeletedIDHistory() {
    deletedID = null;
    return SizedBox.shrink();
  }

  int getDateCountHistory(List<Map<String, dynamic>> data) {
    Set<String> dl = Set();
    for (var i in data) {
      if (!dl.contains(i['date'])) dl.add(i['date']);
    }
    this.historyDateList = dl;
    return historyDateList.length;
  }

  Widget getDailyFutureBuilder() {
    int n = todayTasks.length;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseHelper.getDailyTaskMapList(),
      initialData: List(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.length + n,
                itemBuilder: (_, int position) {
                  if (snapshot.data[0].containsKey('date'))
                    return SizedBox.shrink();
                  var i;
                  if (position >= n) {
                    i = snapshot.data[position - n];
                    dailyChecked[i['id'].toString()] = (i['checked'] == 1);
                  } else {
                    i = todayTasks[position];
                  }
                  return position < n
                      ? Card(
                          color: Colors.white,
                          child: CheckboxListTile(
                            title: Text(i['task']),
                            onChanged: (val) {
                              Future<int> result = databaseHelper
                                  .changeCheckTask(i['id'], val ? 1 : 0);
                              result.then((res) {
                                setState(() {
                                  checked[i['id'].toString()] = val;
                                });
                              });
                            },
                            value: checked[i['id'].toString()],
                          ),
                        )
                      : Card(
                          color: Colors.amber,
                          child: deletedIDDaily != i['id']
                              ? Dismissible(
                                  direction: DismissDirection.endToStart,
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: Icon(Icons.delete_outline),
                                  ),
                                  key: UniqueKey(),
                                  onDismissed: (DismissDirection dd) {
                                    Future<int> res =
                                        databaseHelper.deleteDailyTask(i['id']);
                                    res.then((result) {
                                      setState(() {
                                        deletedIDDaily = i['id'];
                                      });
                                    });
                                  },
                                )
                              : resetDeletedIDDaily());
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  SizedBox resetDeletedIDDaily() {
    deletedIDDaily = null;
    return SizedBox.shrink();
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

  void navigateToDetail() async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TaskDetail();
    }));
    if (result) {
      updateListView();
      updateDailyListView();
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
      setState(() {});
    });
  }

  void updateHistoryListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      var taskMap = databaseHelper.getHistoryMapList();
      taskMap.then((tasklist) {
        setState(() {});
      });
    });
  }
}

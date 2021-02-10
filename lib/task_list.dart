import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_planner/task_detail.dart';
import 'dart:async';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String _lastUpdate;
  Map<String, dynamic> tasksInDate;

  // For keeping track of checked state of general and daily tasks
  Map<String, bool> checked = Map();
  Map<String, bool> dailyChecked = Map();

  // For keeping track of currently opened tab
  int _selectedIndex = 0;

  // For keeping track of tasks scheduled for the current date
  List<Map<String, dynamic>> todayTasks = [];

  // To keep track of dates containing scheduled tasks (for showing as cards)
  Set<String> dateList = {};
  Set<String> historyDateList = {};

  // Used to identify when the next day arrives while the app is opened
  String lastDate;

  // To keep track of the deletedID until removed from database
  int deletedIDDaily;
  int deletedIDHistory;
  int deletedID;

  TextStyle tuteTextStyle = const TextStyle(
    fontSize: 20.0,
    color: Colors.white,
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Runs when app is first opened after being closed
    if (tasksInDate == null) {
      tasksInDate = Map();
      lastDate = formatter.format(DateTime.now());
      updateDailyListView();
      updateListView();
      resetDailyTasks();
    }

    // Runs if the date changes while the app is open
    if (formatter.format(DateTime.now()) != lastDate) {
      resetDailyTasks();
      lastDate = formatter.format(DateTime.now());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text("Task Planner"),
            ),
            IconButton(
              icon: Icon(Icons.help),
              onPressed: navigateToTutorial,
            )
          ],
        ),
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
                  if (lst.length > 0 && lst[position].containsKey('streak'))
                    return SizedBox.shrink();
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
                  if (snapshot.data.length == 0 ||
                      snapshot.data[0].containsKey('date'))
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
                                    secondary: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: new BoxDecoration(
                                        color: Colors.amber[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(i['streak'].toString()),
                                      ),
                                    ),
                                    value: dailyChecked[i['id'].toString()],
                                    onChanged: (bool val) {
                                      Future<int> result =
                                          databaseHelper.changeCheckDailyTask(
                                              i['id'], val ? 1 : 0);
                                      result.then((res) {});

                                      setState(() {
                                        dailyChecked[i['id'].toString()] = val;
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
        } else {
          _lastUpdate = day;
          int difference = formatter
              .parse(formatter.format(DateTime.now()))
              .difference(formatter.parse(_lastUpdate))
              .inDays;
          if (difference == 1) {
            var dTasks = databaseHelper.getDailyTaskMapList();
            dTasks.then((dailyTasks) {
              for (var i in dailyTasks) {
                if (i['checked'] == 1) {
                  databaseHelper.changeStreak(i['id'], true);
                } else {
                  databaseHelper.changeStreak(i['id'], false);
                }
              }
              Future<int> res = databaseHelper.resetDailyTasks();
              res.then((result) {});
            });
          } else if (difference > 1) {
            var dTasks = databaseHelper.getDailyTaskMapList();
            dTasks.then((dailyTasks) {
              for (var i in dailyTasks) {
                databaseHelper.changeStreak(i['id'], false);
              }
              Future<int> res = databaseHelper.resetDailyTasks();
              res.then((result) {});
            });
          }
        }
        prefs.setString('day', formatter.format(DateTime.now()));
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

  void navigateToTutorial() async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OnBoardingPage();
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

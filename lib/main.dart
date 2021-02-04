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

/*
void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final _myController = TextEditingController();
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<String> daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<List<CheckboxListTile>> _lists = [[], []];
  List<DateTime> _dayList = [];

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate, // Refer step 1
        firstDate: _selectedDate,
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != _selectedDate)
        setState(() {
          _selectedDate = picked;
        });
    }

    return MaterialApp(
      title: 'Time Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Time Planner"),
        ),
        body: ListView(
          children: [
            Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _myController,
                )),
            if (_selectedIndex == 0)
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _selectDate(context), // Refer step 3
                    child: Text(
                      'Select date',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    color: Colors.greenAccent,
                  )),
            Container(
                margin: EdgeInsets.all(10.0),
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      _lists[_selectedIndex].add(new CheckboxListTile(
                          value: false,
                          title: Text(_myController.text),
                          onChanged: (bool value) {
                            setState(() {});
                          }));
                      _dayList.add(_selectedDate);
                      _myController.text = " ";
                    });
                  },
                  child: Text("Add Task"),
                  color: Colors.greenAccent,
                )),
            Column(
              children: [
                for (int i = 0; i < _dayList.length; i++)
                  Card(
                    child: Column(
                      children: [
                        if (_selectedIndex == 0)
                          Row(
                            children: [
                              Text(" " + daysOfWeek[_dayList[i].weekday - 1],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text("   " + formatter.format(_dayList[i]),
                                  style: TextStyle(color: Colors.grey))
                            ],
                          ),
                        _lists[_selectedIndex][i],
                      ],
                    ),
                  )
              ],
              //children: _lists[_selectedIndex],
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.view_week), label: "week"),
            BottomNavigationBarItem(icon: Icon(Icons.view_day), label: "day"),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.greenAccent,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}*/

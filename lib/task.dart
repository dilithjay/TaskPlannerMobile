class Task {
  int _id;
  String _task;
  int _checked;
  String _date;

  Task(this._task, this._checked, this._date);
  Task.withId(this._id, this._task, this._checked, this._date);

  int get id => _id;
  String get task => _task;
  int get checked => _checked;
  String get date => _date;

  set task(String newTask) {
    this._task = newTask;
  }

  set checked(int isChecked) {
    this._checked = isChecked;
  }

  set dateTime(String newDate) {
    this._date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['task'] = _task;
    map['checked'] = _checked;
    map['date'] = _date;

    return map;
  }

  Task.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._task = map['task'];
    this._checked = map['checked'];
    this._date = map['date'];
  }
}

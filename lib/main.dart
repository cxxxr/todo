import 'package:flutter/material.dart';

class Task {
  static int counter = 0;

  Task(this.title) : id = counter++;

  String title;
  final int id;
}

class MenuCommand {
  MenuCommand(this.title, this.name);

  final String title;
  final String name;
}

final List<MenuCommand> commands = <MenuCommand>[
  MenuCommand('編集', 'edit'),
];

typedef TaskCallback = void Function(Task task);

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO',
      home: ToDoHome(),
    );
  }
}

class ToDoHome extends StatefulWidget {
  @override
  _ToDoHomeState createState() => _ToDoHomeState();
}

class _ToDoHomeState extends State<ToDoHome> {
  List<Task> _tasks = [];
  Set<Task> _checkedTasks = Set<Task>();
  bool _editMode = false;

  void _doMenuCommand(MenuCommand command) {
    switch (command.name) {
      case 'edit':
        setState(() {
          _editMode = true;
        });
        break;
    }
  }

  void _cancelEditMode() {
    setState(() {
      _editMode = false;
    });
  }

  bool _moreThenOnceIsChecked() {
    return _checkedTasks.length > 0;
  }

  bool _isChecked(Task task) {
    return _checkedTasks.contains(task);
  }

  void _addTask(Task newTask) {
    setState(() {
      _tasks.insert(0, newTask);
    });
  }

  void _clearCheckedTasks() {
    setState(() {
      for (Task task in _checkedTasks) {
        _tasks.remove(task);
      }
      _checkedTasks.clear();
    });
  }

  void _checkTask(Task task) {
    setState(() {
      if (_isChecked(task)) {
        _checkedTasks.remove(task);
      } else {
        _checkedTasks.add(task);
      }
    });
  }

  List<Widget> _buildTaskItems() {
    if (_editMode) {
      return _tasks
          .map((task) => EditableTaskItem(
                key: Key(task.id.toString()),
                task: task,
              ))
          .toList();
    } else {
      return _tasks
          .map((task) => TaskItem(
                key: Key(task.id.toString()),
                task: task,
                isChecked: _isChecked(task),
                onTap: () {
                  _checkTask(task);
                },
              ))
          .toList();
    }
  }

  void _handleReorder(oldIndex, newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final Task task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InputTask(
            onAppend: _addTask,
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: _handleReorder,
              padding: EdgeInsets.all(4.0),
              children: _buildTaskItems(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_editMode) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.cancel),
          onPressed: _cancelEditMode,
        ),
      ];
    } else {
      return <Widget>[
        PopupMenuButton<MenuCommand>(
          onSelected: _doMenuCommand,
          itemBuilder: (BuildContext context) {
            return commands.map((MenuCommand command) {
              return PopupMenuItem(
                child: Text(command.title),
                value: command,
              );
            }).toList();
          },
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO'),
        actions: _buildActions(),
      ),
      body: _buildBody(),
      floatingActionButton: _moreThenOnceIsChecked()
          ? FloatingActionButton(
              child: Icon(Icons.delete),
              onPressed: _clearCheckedTasks,
            )
          : null,
    );
  }
}

mixin TaskItemHelper {
  Widget _build(
    BuildContext context,
    Widget child, {
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 8.0),
    EdgeInsets padding,
  }) {
    return Card(
      child: Container(
        margin: margin,
        padding: padding,
        width: 300,
        height: 50,
        child: child,
      ),
    );
  }
}

class EditableTaskItem extends StatefulWidget {
  EditableTaskItem({key, this.task}) : super(key: key);

  final Task task;

  @override
  _EditableTaskItemState createState() => _EditableTaskItemState();
}

class _EditableTaskItemState extends State<EditableTaskItem>
    with TaskItemHelper {
  TextEditingController controller;

  void _handleChange(String title) {
    setState(() {
      widget.task.title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      controller = new TextEditingController(text: widget.task.title);
    }
    return _build(
      context,
      TextField(
        controller: this.controller,
        onChanged: _handleChange,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
    );
  }
}

class TaskItem extends StatelessWidget with TaskItemHelper {
  TaskItem(
      {key,
      @required this.task,
      @required this.isChecked,
      @required this.onTap})
      : super(key: key);

  final Task task;
  final bool isChecked;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return _build(
      context,
      ListTile(
        leading: CircleAvatar(
          child: isChecked ? Icon(Icons.check) : null,
        ),
        title: Text(task.title),
        onTap: onTap,
      ),
    );
  }
}

class InputTask extends StatefulWidget {
  InputTask({@required this.onAppend});

  final TaskCallback onAppend;

  @override
  _InputTaskState createState() => _InputTaskState();
}

class _InputTaskState extends State<InputTask> {
  TextEditingController _controller = new TextEditingController();

  void _handleSubmitted(String text) {
    if (text.length > 0) {
      widget.onAppend(Task(text));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'タスクを追加',
        ),
        controller: _controller,
        onSubmitted: _handleSubmitted,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: HomePage(),
    );
  }
}
class Task {
  String taskName;
  DateTime deadline;
  bool isCompleted;
  bool showDeleteIcon;

  Task(this.taskName, this.deadline, {this.isCompleted = false, this.showDeleteIcon = false});
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> tasks = [];
  late List<Task> filteredTasks = [];

  TextEditingController taskNameController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override

  void initState() {
    super.initState();
    loadOrSaveTasks(true);
  }

  void loadOrSaveTasks(bool load) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final tasksJsonList = json.decode(tasksJson);
      tasks = tasksJsonList
          .map((taskJson) => Task(taskJson['taskName'], DateTime.parse(taskJson['deadline']),
          isCompleted: taskJson['isCompleted'] ?? false))
          .toList();
    }
    setState(() {
      filteredTasks = tasks;
    });
    if (!load) {
      prefs.setString('tasks', json.encode(tasks));
    }
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    filteredTasks = tasks;
    loadOrSaveTasks(false);

    setState(() {});
  }


  void addTask() {
    final taskName = taskNameController.text;
    final deadline = DateTime.parse(deadlineController.text);

    tasks.add(Task(taskName, deadline));
    loadOrSaveTasks(false);

    taskNameController.text = '';
    deadlineController.text = '';
    searchController.text = '';

    setState(() {
      filteredTasks = tasks;
    });
  }

  bool isTaskOverdue(Task task) {
    return task.deadline.isBefore(DateTime.now());
  }

  void searchTask() {
    final keyword = searchController.text;
    filteredTasks = tasks.where((task) => task.taskName.contains(keyword)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý công việc cá nhân'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Đăng xuất"),
                onPressed: () {
                  Navigator.of(context).popAndPushNamed("/");
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tìm kiếm công việc',
                    ),
                  ),
                ),
                SizedBox(width: 20, height: 20),
                ElevatedButton(
                  onPressed: searchTask,
                  child: Text('Tìm kiếm'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                Task search = tasks[index];
                Task task = filteredTasks[index];
                return ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          task.isCompleted = value!;
                          task.showDeleteIcon = value!;
                          loadOrSaveTasks(true);
                        });
                      },
                    ),
                    title: Text(task.taskName),
                    subtitle: Text('Hết hạn vào: ${task.deadline}'),
                    tileColor: isTaskOverdue(task) ? Colors.red[100] : null,
                    trailing: task.showDeleteIcon ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteTask(index),
                    )
                        :null
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: taskNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tên công việc',
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Thời gian hết hạn (yyyy-MM-dd HH:mm:ss)',
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: addTask,
            child: Text('Thêm công việc mới'),
          ),
          SizedBox(height: 20),



        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_flutter/components/task_card.dart';
import 'package:test_flutter/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  int _calculateTotalDuration() {
    int totalDuration = 0;
    for (var todo in _todos) {
      if (todo['end_time'] != null && todo['start_time'] != null) {
        totalDuration += (DateTime.parse(todo['end_time']).difference(DateTime.parse(todo['start_time']))).inMinutes;
      }
    }
    return totalDuration;
  }
  
  Duration _calculateDuration(String startTime, String endTime) {
  if (startTime.isEmpty || endTime.isEmpty) return Duration.zero;
  try {
    final start = DateTime.parse(startTime); // Direct parsing without intl
    final end = DateTime.parse(endTime);
    return end.difference(start);
  } catch (e) {
    return Duration.zero;
  }
}

  Future<void> _pickDateTime(TextEditingController controller, String label) async {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (date != null) {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          final DateTime dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          controller.text = dateTime.toString();
        }
      }
    }

  Future<void> _fetchTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://demo.urproj.com/api/todos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _todos = jsonDecode(response.body)['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch to-do list.')),
        );
      }
    }
  }

  Future<void> _addTodo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add To-Do'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: startTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Time',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(startTimeController, 'Start Time'),
                ),
              ),
            ),
            TextField(
              controller: endTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Time',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(endTimeController, 'End Time'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (token != null) {
                final response = await http.post(
                  Uri.parse('https://demo.urproj.com/api/todos'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  _fetchTodos();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add to-do.')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTodo(
    int id, 
    String currentTitle, 
    String currentDescription, 
    String currentStartTime, 
    String currentEndTime
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final TextEditingController titleController = TextEditingController(text: currentTitle);
    final TextEditingController descriptionController = TextEditingController(text: currentDescription);
    final TextEditingController startTimeController = TextEditingController(text: currentStartTime);
    final TextEditingController endTimeController = TextEditingController(text: currentEndTime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update To-Do'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: startTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Time',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(startTimeController, 'Start Time'),
                ),
              ),
            ),
            TextField(
              controller: endTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Time',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(endTimeController, 'End Time'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (token != null) {
                final response = await http.put(
                  Uri.parse('https://demo.urproj.com/api/todos/$id'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  _fetchTodos();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update to-do.')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTodo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.delete(
        Uri.parse('https://demo.urproj.com/api/todos/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _fetchTodos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete to-do.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Welcome, users!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_rounded),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: const Color.fromARGB(255, 161, 67, 205),
                  fillColor: const Color.fromARGB(255, 161, 67, 205),
                  isSelected: const [true],
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Today'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wednesday',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '15.24',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'JAN',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '1:20 PM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'WIB',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '2:20 PM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'WITA',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's tasks",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ${_calculateTotalDuration()} mins',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  final duration = _calculateDuration(todo['start_time'] ?? '', todo['end_time'] ?? '');
                  return TaskCard(
                    title: todo['title'] ?? '',
                    startTime: todo['start_time'],
                    endTime: todo['end_time'],
                    duration: duration.inMinutes, 
                    backgroundColor: const Color.fromARGB(255, 161, 67, 205),
                    participants: const [],
                    onUpdate: () => _updateTodo(
                      todo['id'],
                      todo['title'] ?? '',
                      todo['description'] ?? '',
                      todo['start_time'] ?? '',
                      todo['end_time'] ?? '',
                    ),
                    onDelete: () => _deleteTodo(todo['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

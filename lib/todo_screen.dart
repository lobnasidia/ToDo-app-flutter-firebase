import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ToDoScreen extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference get tasksCollection =>
      FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('tasks');

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      tasksCollection.add({'task': _taskController.text, 'completed': false});
      _taskController.clear();
    }
  }

  void _deleteTask(String id) {
    tasksCollection.doc(id).delete();
  }

  void _toggleTaskCompletion(String id, bool currentStatus) {
    tasksCollection.doc(id).update({'completed': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: Text('Add Task'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(
                        task['task'],
                        style: TextStyle(
                          decoration: task['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task['completed'],
                            onChanged: (value) =>
                                _toggleTaskCompletion(task.id, task['completed']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

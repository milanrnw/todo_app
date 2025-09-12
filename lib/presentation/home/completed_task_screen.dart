import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_todo_app/models/task_details.dart';
import 'package:new_todo_app/util/appconstant.dart';
import 'package:new_todo_app/util/firestore_collection.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({super.key});

  @override
  State<CompletedTaskScreen> createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {
  final List<TaskDetails> _completedTasks = [];
  bool isLoading = false;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final firestore = FirebaseFirestore.instance;

  Future<void> fetchAllTask() async {
    setState(() {
      isLoading = true;
    });

    final todosnap = await firestore
        .collection(FirestoreCollection.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollection.todosCollection)
        .where("isDone", isEqualTo: true)
        .get();

    final todos = todosnap.docs;

    todos
        .map((element) =>
            _completedTasks.add(TaskDetails.fromJson(element.data())))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> markAsIncompleted(TaskDetails task) async {
    await firestore
        .collection(FirestoreCollection.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollection.todosCollection)
        .doc(task.id)
        .update({
      "isDone": false,
    }).then((value) {
      Appconstant.showSnackBar(context,
          message: "Removed from completed task list", isSuccess: true);
    });
  }

  Future<void> _deleteTask(int index) async {
    if (uid == null) {
      Appconstant.showSnackBar(context,
          message: "User not logged in.", isSuccess: false);
      return;
    }

    final taskToDelete = _completedTasks[index];

    try {
      await firestore
          .collection(FirestoreCollection.todoListCollection)
          .doc(uid)
          .collection(FirestoreCollection.todosCollection)
          .doc(taskToDelete.id)
          .delete();

      setState(() {
        _completedTasks.removeAt(index);
      });

      if (mounted) {
        Appconstant.showSnackBar(context,
            message: "Task deleted successfully", isSuccess: true);
      }
    } catch (e) {
      debugPrint("Error deleting task: $e");
      if (mounted) {
        Appconstant.showSnackBar(context,
            message: "Error deleting task", isSuccess: false);
      }
    }
  }

  @override
  void initState() {
    fetchAllTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _completedTasks.isEmpty
                ? Center(
                    child: Text(
                      'No completed tasks yet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _completedTasks.length,
                    separatorBuilder: (context, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = _completedTasks[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (value) async {
                              await markAsIncompleted(task);
                              setState(() {
                                _completedTasks.remove(task);
                              });
                            },
                          ),
                          title: Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: task.description.isNotEmpty
                              ? Text(task.description)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _deleteTask(
                              index,
                            ),
                            tooltip: 'Delete',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

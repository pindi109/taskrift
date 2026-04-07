import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentProjectFilter;
  StreamSubscription<List<TaskModel>>? _taskSubscription;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentProjectFilter => _currentProjectFilter;

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      final taskDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return taskDate == today;
    }).toList();
  }

  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      final taskDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return taskDate.isBefore(today);
    }).toList();
  }

  List<TaskModel> getTasksByProject(String projectId) =>
      _tasks.where((t) => t.projectId == projectId).toList();

  void loadTasks({String? projectId}) {
    _taskSubscription?.cancel();
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    _isLoading = true;
    _currentProjectFilter = projectId;
    notifyListeners();
    final stream = projectId != null
        ? _taskService.getTasksByProjectStream(userId, projectId)
        : _taskService.getTasksStream(userId);
    _taskSubscription = stream.listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createTask({
    required String title,
    String? note,
    required String projectId,
    DateTime? dueDate,
    String priority = 'medium',
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      await _taskService.createTask(
        userId: userId,
        title: title,
        note: note,
        projectId: projectId,
        dueDate: dueDate,
        priority: priority,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      await _taskService.updateTask(userId, task);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    // Optimistic update
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
    }
    try {
      await _taskService.toggleTaskCompletion(userId, task);
      return true;
    } catch (e) {
      // Rollback
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      await _taskService.deleteTask(userId, task);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}

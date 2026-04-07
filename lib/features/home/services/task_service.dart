import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../../../core/constants/app_constants.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference _tasksRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.tasksCollection);
  }

  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _tasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<TaskModel>> getTasksByProjectStream(
      String userId, String projectId) {
    return _tasksRef(userId)
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<TaskModel> createTask({
    required String userId,
    required String title,
    String? note,
    required String projectId,
    DateTime? dueDate,
    String priority = 'medium',
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final task = TaskModel(
        id: id,
        title: title,
        note: note,
        projectId: projectId,
        dueDate: dueDate,
        priority: priority,
        status: AppConstants.statusTodo,
        isCompleted: false,
        labels: [],
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );
      await _tasksRef(userId).doc(id).set(task.toMap());
      await _updateProjectCount(userId, projectId, 1, 0);
      return task;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await _tasksRef(userId).doc(task.id).update(updatedTask.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> toggleTaskCompletion(
      String userId, TaskModel task) async {
    try {
      final newCompleted = !task.isCompleted;
      await _tasksRef(userId).doc(task.id).update({
        'isCompleted': newCompleted,
        'status': newCompleted
            ? AppConstants.statusDone
            : AppConstants.statusTodo,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _updateProjectCount(
          userId, task.projectId, 0, newCompleted ? 1 : -1);
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }

  Future<void> deleteTask(String userId, TaskModel task) async {
    try {
      await _tasksRef(userId).doc(task.id).delete();
      await _updateProjectCount(userId, task.projectId, -1,
          task.isCompleted ? -1 : 0);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<void> moveTaskToProject(
      String userId, TaskModel task, String newProjectId) async {
    try {
      final oldProjectId = task.projectId;
      await _tasksRef(userId).doc(task.id).update({
        'projectId': newProjectId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _updateProjectCount(userId, oldProjectId, -1,
          task.isCompleted ? -1 : 0);
      await _updateProjectCount(userId, newProjectId, 1,
          task.isCompleted ? 1 : 0);
    } catch (e) {
      throw Exception('Failed to move task: $e');
    }
  }

  Future<void> _updateProjectCount(
      String userId, String projectId, int taskDelta, int completedDelta) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .update({
        'taskCount': FieldValue.increment(taskDelta),
        'completedCount': FieldValue.increment(completedDelta),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

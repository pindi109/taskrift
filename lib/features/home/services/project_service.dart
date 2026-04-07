import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../../../core/constants/app_constants.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference _projectsRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.projectsCollection);
  }

  Stream<List<ProjectModel>> getProjectsStream(String userId) {
    return _projectsRef(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ProjectModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<ProjectModel> createProject({
    required String userId,
    required String name,
    String color = '#7C3AED',
    String icon = 'folder',
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final project = ProjectModel(
        id: id,
        name: name,
        color: color,
        icon: icon,
        isDefault: false,
        taskCount: 0,
        completedCount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await _projectsRef(userId).doc(id).set(project.toMap());
      return project;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<void> updateProject(
      String userId, ProjectModel project) async {
    try {
      final updated = project.copyWith(updatedAt: DateTime.now());
      await _projectsRef(userId).doc(project.id).update(updated.toMap());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(
      String userId, String projectId) async {
    try {
      // Move tasks to inbox
      final tasks = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.tasksCollection)
          .where('projectId', isEqualTo: projectId)
          .get();
      final batch = _firestore.batch();
      for (final doc in tasks.docs) {
        batch.update(doc.reference, {
          'projectId': AppConstants.defaultProjectId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      batch.delete(_projectsRef(userId).doc(projectId));
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}

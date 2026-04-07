import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<ProjectModel>>? _projectSubscription;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProjectModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void loadProjects() {
    _projectSubscription?.cancel();
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    _isLoading = true;
    notifyListeners();
    _projectSubscription =
        _projectService.getProjectsStream(userId).listen(
      (projects) {
        _projects = projects;
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

  Future<bool> createProject({
    required String name,
    String color = '#7C3AED',
    String icon = 'folder',
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      await _projectService.createProject(
        userId: userId,
        name: name,
        color: color,
        icon: icon,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(ProjectModel project) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      await _projectService.updateProject(userId, project);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      await _projectService.deleteProject(userId, projectId);
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
    _projectSubscription?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../models/project_model.dart';
import '../widgets/project_card.dart';
import '../widgets/add_project_sheet.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer2<ProjectProvider, TaskProvider>(
                builder: (context, projectProvider, taskProvider, _) {
                  if (projectProvider.isLoading) {
                    return const Center(child: LoadingWidget());
                  }
                  if (projectProvider.errorMessage != null) {
                    return Center(
                      child: Text(
                        projectProvider.errorMessage!,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                    );
                  }
                  if (projectProvider.projects.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: projectProvider.projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final project = projectProvider.projects[i];
                      final tasks = taskProvider.getTasksByProject(project.id);
                      final completed = tasks.where((t) => t.isCompleted).length;
                      return ProjectCard(
                        project: project,
                        taskCount: tasks.length,
                        completedCount: completed,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProjectDetailScreen(project: project),
                          ),
                        ),
                        onDelete: project.isDefault
                            ? null
                            : () => _confirmDelete(context, project),
                        onEdit: project.isDefault
                            ? null
                            : () => _showEditSheet(context, project),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddProjectSheet(),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Projects',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
          ),
          Consumer<ProjectProvider>(
            builder: (context, provider, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${provider.projects.length} projects',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_outlined, color: AppTheme.primary, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'No projects yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a project to organise\nyour tasks better',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Project', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${project.name}"? Tasks will be moved to Inbox.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProjectProvider>().deleteProject(project.id);
    }
  }

  void _showEditSheet(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectSheet(editProject: project),
    );
  }
}

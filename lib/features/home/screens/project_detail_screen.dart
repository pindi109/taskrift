import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_sheet.dart';
import '../../../shared/widgets/loading_widget.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _projectColor {
    try {
      return Color(int.parse(
          widget.project.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer2<TaskProvider, ProjectProvider>(
          builder: (context, taskProvider, projectProvider, _) {
            final project = projectProvider.getProjectById(widget.project.id) ?? widget.project;
            final allTasks = taskProvider.getTasksByProject(project.id);
            final pending = allTasks.where((t) => !t.isCompleted).toList();
            final completed = allTasks.where((t) => t.isCompleted).toList();
            final progress = allTasks.isEmpty ? 0.0 : completed.length / allTasks.length;

            return Column(
              children: [
                _buildAppBar(context, project),
                _buildStats(project, allTasks.length, completed.length, progress),
                _buildTabBar(),
                Expanded(
                  child: taskProvider.isLoading
                      ? const Center(child: LoadingWidget())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTaskList(pending, 'No pending tasks', project),
                            _buildTaskList(completed, 'No completed tasks', project),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          return FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTaskSheet(
                projects: projectProvider.projects,
                defaultProjectId: widget.project.id,
              ),
            ),
            backgroundColor: _projectColor,
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ProjectModel project) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _projectColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getProjectIcon(project.icon),
              color: _projectColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              project.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      ProjectModel project, int total, int completed, double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatItem('Total', '$total', Icons.list_rounded),
                _buildStatItem('Completed', '$completed', Icons.check_circle_outline_rounded),
                _buildStatItem('Pending', '${total - completed}', Icons.radio_button_unchecked_rounded),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(_projectColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: _projectColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: _projectColor,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(
      List<TaskModel> tasks, String emptyMessage, ProjectModel project) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _projectColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.task_outlined, color: _projectColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => TaskTile(task: tasks[i], project: project),
    );
  }

  IconData _getProjectIcon(String icon) {
    switch (icon) {
      case 'inbox':
        return Icons.inbox_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.favorite_outline_rounded;
      case 'finance':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.folder_outlined;
    }
  }
}

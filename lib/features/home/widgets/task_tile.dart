import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import 'edit_task_sheet.dart';
import '../../../core/utils/date_utils.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final ProjectModel? project;

  const TaskTile({super.key, required this.task, this.project});

  Color get _priorityColor {
    switch (task.priority) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get _projectColor {
    if (project == null) return AppTheme.primary;
    try {
      return Color(int.parse(project!.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Task', style: TextStyle(color: AppTheme.textPrimary)),
            content: const Text(
              'Are you sure you want to delete this task?',
              style: TextStyle(color: AppTheme.textSecondary),
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
      },
      onDismissed: (_) {
        context.read<TaskProvider>().deleteTask(task);
      },
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => EditTaskSheet(
            task: task,
            projects: context.read<ProjectProvider>().projects,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.isCompleted
                  ? AppTheme.border
                  : _priorityColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(context),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
              const SizedBox(width: 8),
              _buildPriorityIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<TaskProvider>().toggleTaskCompletion(task),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.isCompleted ? AppTheme.success : Colors.transparent,
          border: Border.all(
            color: task.isCompleted ? AppTheme.success : AppTheme.textSecondary,
            width: 1.5,
          ),
        ),
        child: task.isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
            : null,
      ),
    );
  }

  Widget _buildContent() {
    final isOverdue = TaskDateUtils.isOverdue(task.dueDate) && !task.isCompleted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: task.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: AppTheme.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (task.note != null && task.note!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            task.note!,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            if (task.dueDate != null)
              _buildChip(
                icon: Icons.schedule_rounded,
                label: TaskDateUtils.formatDate(task.dueDate),
                color: isOverdue ? AppTheme.error : AppTheme.textSecondary,
              ),
            if (project != null)
              _buildChip(
                icon: Icons.circle,
                label: project!.name,
                color: _projectColor,
                isSmallIcon: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    bool isSmallIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallIcon ? 8 : 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: _priorityColor.withOpacity(task.isCompleted ? 0.3 : 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

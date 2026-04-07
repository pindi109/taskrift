import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../providers/task_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/loading_widget.dart';

class EditTaskSheet extends StatefulWidget {
  final TaskModel task;
  final List<ProjectModel> projects;

  const EditTaskSheet({super.key, required this.task, required this.projects});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late String _selectedProjectId;
  DateTime? _dueDate;
  late String _priority;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.note ?? '');
    _selectedProjectId = widget.task.projectId;
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      projectId: _selectedProjectId,
      dueDate: _dueDate,
      clearDueDate: _dueDate == null,
      priority: _priority,
      updatedAt: DateTime.now(),
    );
    final success = await context.read<TaskProvider>().updateTask(updatedTask);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Delete Task', style: TextStyle(color: AppTheme.textPrimary)),
                          content: const Text('Are you sure?', style: TextStyle(color: AppTheme.textSecondary)),
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
                        context.read<TaskProvider>().deleteTask(widget.task);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      validator: Validators.validateTaskTitle,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Task title...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Add a note...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.border),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDateChip(),
                  _buildPrioritySelector(),
                  _buildProjectSelector(),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const LoadingWidget(size: 20, color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _dueDate != null
                  ? AppTheme.primaryLight.withOpacity(0.15)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _dueDate != null
                    ? AppTheme.primaryLight.withOpacity(0.4)
                    : AppTheme.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: _dueDate != null ? AppTheme.primaryLight : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _dueDate == null ? 'Due date' : DateFormat('MMM d').format(_dueDate!),
                  style: TextStyle(
                    color: _dueDate != null ? AppTheme.primaryLight : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_dueDate != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _dueDate = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrioritySelector() {
    const priorities = [
      ('low', 'Low', Color(0xFF6B7280)),
      ('medium', 'Medium', Color(0xFFF59E0B)),
      ('high', 'High', Color(0xFFF97316)),
      ('urgent', 'Urgent', Color(0xFFEF4444)),
    ];
    return PopupMenuButton<String>(
      onSelected: (v) => setState(() => _priority = v),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border)),
      itemBuilder: (_) => priorities
          .map((p) => PopupMenuItem(
                value: p.$1,
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, color: p.$3, size: 16),
                    const SizedBox(width: 8),
                    Text(p.$2, style: const TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getPriorityColor(_priority).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _getPriorityColor(_priority).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 16, color: _getPriorityColor(_priority)),
            const SizedBox(width: 6),
            Text(
              _priority[0].toUpperCase() + _priority.substring(1),
              style: TextStyle(
                color: _getPriorityColor(_priority),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector() {
    if (widget.projects.isEmpty) return const SizedBox.shrink();
    final selectedProject = widget.projects
        .cast<ProjectModel?>()
        .firstWhere((p) => p?.id == _selectedProjectId, orElse: () => null);
    return PopupMenuButton<String>(
      onSelected: (v) => setState(() => _selectedProjectId = v),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border)),
      itemBuilder: (_) => widget.projects
          .map((p) => PopupMenuItem(
                value: p.id,
                child: Text(p.name, style: const TextStyle(color: AppTheme.textPrimary)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_outlined, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              selectedProject?.name ?? 'Project',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/project_model.dart';
import '../providers/task_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/loading_widget.dart';

class AddTaskSheet extends StatefulWidget {
  final List<ProjectModel> projects;
  final String defaultProjectId;

  const AddTaskSheet({
    super.key,
    required this.projects,
    required this.defaultProjectId,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late String _selectedProjectId;
  DateTime? _dueDate;
  String _priority = 'medium';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.defaultProjectId;
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
    final success = await context.read<TaskProvider>().createTask(
          title: _titleController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          projectId: _selectedProjectId,
          dueDate: _dueDate,
          priority: _priority,
        );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
              const SizedBox(height: 20),
              const Text(
                'New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      validator: Validators.validateTaskTitle,
                      autofocus: true,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Task title...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 18,
                        ),
                      ),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
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
              _buildOptions(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildOptionChip(
          icon: Icons.schedule_outlined,
          label: _dueDate == null
              ? 'Due date'
              : DateFormat('MMM d').format(_dueDate!),
          onTap: _pickDate,
          color: _dueDate != null ? AppTheme.primaryLight : AppTheme.textSecondary,
          selected: _dueDate != null,
        ),
        _buildPrioritySelector(),
        _buildProjectSelector(),
      ],
    );
  }

  Widget _buildOptionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.15)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color.withOpacity(0.4) : AppTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
                child: Text(p.name,
                    style: const TextStyle(color: AppTheme.textPrimary)),
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
              selectedProject?.name ?? 'Select Project',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const LoadingWidget(size: 20, color: Colors.white)
            : const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

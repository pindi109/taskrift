import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/loading_widget.dart';

class AddProjectSheet extends StatefulWidget {
  final ProjectModel? editProject;

  const AddProjectSheet({super.key, this.editProject});

  @override
  State<AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<AddProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedColor = '#7C3AED';
  String _selectedIcon = 'folder';
  bool _isLoading = false;

  static const List<String> _colors = [
    '#7C3AED',
    '#3B82F6',
    '#10B981',
    '#F59E0B',
    '#EF4444',
    '#EC4899',
    '#14B8A6',
    '#F97316',
    '#8B5CF6',
    '#6366F1',
  ];

  static const List<(String, IconData)> _icons = [
    ('folder', Icons.folder_outlined),
    ('work', Icons.work_outline_rounded),
    ('personal', Icons.person_outline_rounded),
    ('shopping', Icons.shopping_bag_outlined),
    ('health', Icons.favorite_outline_rounded),
    ('finance', Icons.account_balance_wallet_outlined),
    ('home', Icons.home_outlined),
    ('school', Icons.school_outlined),
  ];

  bool get _isEditing => widget.editProject != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editProject?.name ?? '',
    );
    if (_isEditing) {
      _selectedColor = widget.editProject!.color;
      _selectedIcon = widget.editProject!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<ProjectProvider>();
    bool success;
    if (_isEditing) {
      success = await provider.updateProject(
        widget.editProject!.copyWith(
          name: _nameController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        ),
      );
    } else {
      success = await provider.createProject(
        name: _nameController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
      );
    }
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
              const SizedBox(height: 20),
              Text(
                _isEditing ? 'Edit Project' : 'New Project',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  validator: Validators.validateProjectName,
                  autofocus: true,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g. Work, Personal...',
                    prefixIcon: Icon(Icons.drive_file_rename_outline_rounded,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildColorPicker(),
              const SizedBox(height: 20),
              const Text(
                'Icon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildIconPicker(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const LoadingWidget(size: 20, color: Colors.white)
                      : Text(
                          _isEditing ? 'Save Changes' : 'Create Project',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colors.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseColor(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: _parseColor(color).withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _icons.map((iconData) {
        final isSelected = iconData.$1 == _selectedIcon;
        final color = _parseColor(_selectedColor);
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconData.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppTheme.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Icon(
              iconData.$2,
              color: isSelected ? color : AppTheme.textSecondary,
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }
}

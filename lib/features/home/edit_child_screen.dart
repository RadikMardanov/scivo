import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common.dart';

/// Экран редактирования имени и класса ребёнка.
class EditChildScreen extends ConsumerStatefulWidget {
  const EditChildScreen({super.key, required this.child});
  final ChildProfile child;

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  late TextEditingController _nameController;
  late int _selectedGrade;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.nickname);
    _selectedGrade = widget.child.grade;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      await service.updateChild(
        childId: widget.child.id,
        nickname: _nameController.text.trim(),
        grade: _selectedGrade,
      );
      // Обновляем список детей
      ref.invalidate(childrenProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Редактировать героя',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Имя героя:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: 'Например, Тагир',
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Класс:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(4, (index) {
              final grade = index + 1;
              return RadioListTile<int>(
                value: grade,
                groupValue: _selectedGrade,
                onChanged: (val) => setState(() => _selectedGrade = val!),
                title: Text('$grade класс'),
                controlAffinity: ListTileControlAffinity.trailing,
              );
            }),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: Text(_isLoading ? 'Сохраняем...' : 'Сохранить изменения'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

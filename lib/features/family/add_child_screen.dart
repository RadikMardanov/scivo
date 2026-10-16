import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/scivo_raven.dart';

/// Экран создания нового героя (ребёнка).
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key, this.isFirst = false});
  final bool isFirst;

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _nameController = TextEditingController();
  String _selectedAvatar = 'raven_blue';
  int _selectedGrade = 1;
  String _pin = '';
  int _step = 0; // 0=name/avatar, 1=grade, 2=pin
  bool _isLoading = false;

  static const _avatars = ['raven_blue', 'raven_green', 'raven_red', 'raven_yellow', 'raven_purple', 'raven_black'];
  static const _grades = [1, 2, 3, 4];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (_nameController.text.trim().isEmpty) {
        showSnack(context, 'Введите имя героя', isError: true);
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 2);
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  void _onDigit(String d) {
    if (_pin.length < 4) setState(() => _pin += d);
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _finish() async {
    if (_pin.length != 4) {
      showSnack(context, 'PIN должен состоять из 4 цифр', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      await service.createChild(
        nickname: _nameController.text.trim(),
        avatarId: _selectedAvatar,
        grade: _selectedGrade,
        pin: _pin,
      );
      ref.invalidate(childrenProvider);
      if (mounted) {
        // ИСПРАВЛЕНО: $_name не существовал, читаем значение из контроллера.
        final name = _nameController.text.trim();
        showSnack(context, 'Герой $name готов к приключениям! 🎉');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Новый герой',
      showBack: !widget.isFirst,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: ScivoRaven(size: 80, avatarId: _selectedAvatar)),
            const SizedBox(height: 16),

            if (_step == 0) ...[
              Text('Как звать героя?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                maxLength: 20,
                decoration: magicInput('Имя героя', icon: Icons.face_retouching_natural_rounded),
              ),
              const SizedBox(height: 24),
              Text('Выберите цвет оперения:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _avatars.map((a) => GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = a),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedAvatar == a ? AppColors.gold : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedAvatar == a ? AppColors.textDark : Colors.transparent, width: 2),
                    ),
                    child: ScivoRaven(size: 48, avatarId: a, animated: false),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton(onPressed: _nextStep, child: const Text('Далее')),
            ] else if (_step == 1) ...[
              Text('Какой класс?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _grades.map((g) => ChoiceChip(
                  label: Text('$g класс'),
                  selected: _selectedGrade == g,
                  onSelected: (_) => setState(() => _selectedGrade = g),
                  selectedColor: AppColors.gold,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                )).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _prevStep, child: const Text('Назад'))),
                  const SizedBox(width: 16),
                  Expanded(child: FilledButton(onPressed: _nextStep, child: const Text('Далее'))),
                ],
              ),
            ] else ...[
              Text('Придумайте PIN (4 цифры)', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: i < _pin.length ? Colors.white : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                )),
              ),
              const SizedBox(height: 24),
              PinPad(
                onDigit: _onDigit,
                onDelete: _onDelete,
                onOk: _finish,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _prevStep, child: const Text('Назад')),
            ],
          ],
        ),
      ),
    );
  }
}

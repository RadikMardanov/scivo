import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/raven_art.dart';
import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/scivo_raven.dart';

/// Создание профиля ребёнка: имя -> класс -> цвет вороненка -> PIN (2 раза).
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key, this.isFirst = false});

  final bool isFirst;

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _name = TextEditingController();
  int _step = 0;
  int? _grade;
  String _avatar = RavenArt.avatars.first.id;
  String? _pin;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toPin() {
    if (_name.text.trim().isEmpty) {
      setState(() => _message = 'Введите имя или никнейм героя.');
      return;
    }
    if (_grade == null) {
      setState(() => _message = 'Выберите класс.');
      return;
    }
    setState(() {
      _message = null;
      _step = 1;
    });
  }

  Future<bool> _onFirstPin(String pin) async {
    setState(() {
      _pin = pin;
      _step = 2;
      _message = null;
    });
    return true;
  }

  Future<bool> _onConfirmPin(String pin) async {
    if (pin != _pin) {
      setState(() {
        _pin = null;
        _step = 1;
        _message = 'PIN не совпал. Придумайте ещё раз.';
      });
      return false;
    }

    final name = _name.text.trim();
    try {
      await ref.read(serviceProvider).createChild(
            nickname: name,
            avatarId: _avatar,
            grade: _grade ?? 1,
            pin: pin,
          );
      if (!mounted) return true;
      showSnack(context, 'Герой $name готов к приключениям! 🎉');
      final navigator = Navigator.of(context);
      final isFirst = widget.isFirst;
      ref.invalidate(childrenProvider);
      if (!isFirst && navigator.canPop()) navigator.pop();
      return true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _step = 1;
          _pin = null;
          _message = friendlyError(error);
        });
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final message = _message;
    final name = _name.text.trim();

    return MagicScaffold(
      title: 'Новый герой',
      showBack: !widget.isFirst,
      actions: widget.isFirst
          ? [
              IconButton(
                tooltip: 'Выйти',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => ref.read(serviceProvider).signOut(),
              ),
            ]
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_step == 0) ..._buildDetails(text),
                if (_step == 1) ...[
                  ScivoRaven(avatarId: _avatar, size: 110),
                  const SizedBox(height: 12),
                  Text(
                    'Придумайте PIN для $name',
                    textAlign: TextAlign.center,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '4 цифры. Ребёнок будет вводить их при входе — запишите PIN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  PinPad(key: const ValueKey('child-pin-1'), onCompleted: _onFirstPin),
                  TextButton(
                    onPressed: () => setState(() {
                      _step = 0;
                      _message = null;
                    }),
                    child: const Text('Назад'),
                  ),
                ],
                if (_step == 2) ...[
                  ScivoRaven(avatarId: _avatar, size: 110),
                  const SizedBox(height: 12),
                  Text(
                    'Повторите PIN',
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  PinPad(key: const ValueKey('child-pin-2'), onCompleted: _onConfirmPin),
                  TextButton(
                    onPressed: () => setState(() {
                      _step = 1;
                      _pin = null;
                    }),
                    child: const Text('Назад'),
                  ),
                ],
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails(TextTheme text) {
    return [
      ScivoSays(
        size: 100,
        avatarId: _avatar,
        text: widget.isFirst
            ? 'Давайте создадим первого героя! Как его зовут?'
            : 'Новый герой? Отлично! Как его зовут?',
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _name,
        maxLength: 20,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        decoration: magicInput(
          'Имя или никнейм',
          icon: Icons.face_rounded,
          hint: 'Например, Тагир',
        ),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Класс', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          for (var g = 1; g <= 4; g++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _GradeButton(
                  grade: g,
                  selected: _grade == g,
                  onTap: () => setState(() => _grade = g),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Цвет вороненка',
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          for (final option in RavenArt.avatars)
            _AvatarChoice(
              avatarId: option.id,
              label: option.label,
              selected: _avatar == option.id,
              onTap: () => setState(() => _avatar = option.id),
            ),
        ],
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: FilledButton(onPressed: _toPin, child: const Text('Дальше')),
      ),
    ];
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.grade,
    required this.selected,
    required this.onTap,
  });

  final int grade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.purple : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.gold : Colors.white24,
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$grade',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const Text('класс', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatarId,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String avatarId;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 86,
          height: 86,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.18 : 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
          child: ScivoRaven(avatarId: avatarId, size: 70, animated: false),
        ),
      ),
    );
  }
}

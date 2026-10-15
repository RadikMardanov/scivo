import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import 'parent_zone_screen.dart';

/// Родительский замок: пример на умножение + PIN родителя (проверка на сервере).
class ParentGateScreen extends ConsumerStatefulWidget {
  const ParentGateScreen({super.key});

  @override
  ConsumerState<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends ConsumerState<ParentGateScreen> {
  final _random = math.Random();
  final _answer = TextEditingController();
  int _a = 7;
  int _b = 8;
  bool _mathPassed = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _newTask();
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _newTask() {
    _a = 6 + _random.nextInt(4);
    _b = 6 + _random.nextInt(4);
    _answer.clear();
  }

  void _checkMath() {
    if (int.tryParse(_answer.text.trim()) == _a * _b) {
      setState(() {
        _mathPassed = true;
        _message = null;
      });
    } else {
      setState(() {
        _message = 'Неверно. Вот новый пример.';
        _newTask();
      });
    }
  }

  Future<bool> _onPin(String pin) async {
    try {
      final result = await ref.read(serviceProvider).verifyParentPin(pin);
      if (!mounted) return false;
      if (result.ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ParentZoneScreen()),
        );
        return true;
      }
      setState(() => _message = result.message);
      return false;
    } catch (error) {
      if (mounted) setState(() => _message = friendlyError(error));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final message = _message;

    return MagicScaffold(
      title: 'Для взрослых',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_mathPassed) ...[
                  const Text('🔒', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text('Этот раздел для родителей', style: text.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    'Сколько будет $_a × $_b?',
                    style: text.headlineSmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _answer,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    decoration: magicInput('Ответ'),
                    onSubmitted: (_) => _checkMath(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _checkMath,
                      child: const Text('Продолжить'),
                    ),
                  ),
                ] else ...[
                  Text('Введите PIN родителя', style: text.titleLarge),
                  const SizedBox(height: 16),
                  PinPad(onCompleted: _onPin),
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
}

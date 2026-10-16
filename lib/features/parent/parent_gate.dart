import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/scivo_raven.dart';

/// Родительский гейт: проверка PIN перед доступом в зону управления.
class ParentGate extends ConsumerStatefulWidget {
  const ParentGate({super.key, required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  ConsumerState<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends ConsumerState<ParentGate> {
  String _pin = '';
  bool _isLoading = false;
  int _attempts = 0;

  void _onDigit(String d) {
    if (_pin.length < 4) setState(() => _pin += d);
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    if (_pin.length != 4) return;
    
    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      final result = await service.verifyParentPin(_pin);
      if (result.ok) {
        widget.onSuccess();
      } else {
        _attempts++;
        if (_attempts >= 5) {
          showSnack(context, 'Слишком много попыток. Подождите 5 минут.', isError: true);
          // TODO: реализовать lockout на сервере
        } else {
          showSnack(context, result.message, isError: true);
        }
        setState(() => _pin = '');
      }
    } catch (e) {
      showSnack(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Вход для взрослых',
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScivoRaven(size: 96, avatarId: 'raven_blue'),
                  const SizedBox(height: 16),
                  Text('Введите PIN родителя', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: PinPad(
              onDigit: _onDigit,
              onDelete: _onDelete,
              onOk: _verify,
              enabled: !_isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

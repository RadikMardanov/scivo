import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/scivo_raven.dart';

/// Экран установки PIN-кода родителя (первый вход после регистрации).
class ParentPinSetup extends ConsumerStatefulWidget {
  const ParentPinSetup({super.key});

  @override
  ConsumerState<ParentPinSetup> createState() => _ParentPinSetupState();
}

class _ParentPinSetupState extends ConsumerState<ParentPinSetup> {
  String _pin = '';
  bool _isLoading = false;

  void _onDigit(String d) {
    if (_pin.length < 4) setState(() => _pin += d);
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _save() async {
    if (_pin.length != 4) {
      showSnack(context, 'PIN должен состоять из 4 цифр', isError: true);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      await service.setParentPin(_pin);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'PIN родителя',
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScivoRaven(size: 96, avatarId: 'raven_blue'),
                  const SizedBox(height: 16),
                  Text('Придумайте 4-значный PIN', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
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
              onOk: _save,
              enabled: !_isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

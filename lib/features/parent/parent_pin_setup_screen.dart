import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';

class ParentPinSetupScreen extends ConsumerStatefulWidget {
  const ParentPinSetupScreen({super.key});

  @override
  ConsumerState<ParentPinSetupScreen> createState() => _ParentPinSetupScreenState();
}

class _ParentPinSetupScreenState extends ConsumerState<ParentPinSetupScreen> {
  String? _first;
  String? _message;

  Future<bool> _onPin(String pin) async {
    if (_first == null) {
      setState(() {
        _first = pin;
        _message = null;
      });
      return true;
    }
    if (pin != _first) {
      setState(() {
        _first = null;
        _message = 'PIN не совпал. Придумайте ещё раз.';
      });
      return false;
    }
    try {
      await ref.read(serviceProvider).setParentPin(pin);
      ref.invalidate(parentProvider);
      return true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _first = null;
          _message = friendlyError(error);
        });
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    return MagicScaffold(
      title: 'PIN родителя',
      showBack: false,
      actions: [
        IconButton(
          tooltip: 'Выйти',
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => ref.read(serviceProvider).signOut(),
        ),
      ],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ScivoSays(
                  size: 110,
                  text: 'Сначала защитим родительскую зону. '
                      'Придумайте PIN из 4 цифр — детям его не говорите!',
                ),
                const SizedBox(height: 20),
                Text(
                  _first == null ? 'Придумайте PIN' : 'Повторите PIN',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                PinPad(
                  key: ValueKey(_first == null ? 'parent-pin-1' : 'parent-pin-2'),
                  onCompleted: _onPin,
                ),
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

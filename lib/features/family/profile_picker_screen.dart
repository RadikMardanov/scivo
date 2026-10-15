import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/scivo_raven.dart';
import '../parent/parent_gate_screen.dart';

/// «Кто сегодня играет?» — выбор героя и вход по PIN.
class ProfilePickerScreen extends ConsumerWidget {
  const ProfilePickerScreen({super.key, required this.kids});

  final List<ChildProfile> kids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return MagicScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ScivoRaven(size: 110),
                const SizedBox(height: 8),
                Text(
                  'Кто сегодня играет?',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final kid in kids)
                      _KidTile(
                        kid: kid,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChildPinScreen(kid: kid),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ParentGateScreen()),
                  ),
                  icon: const Icon(Icons.lock_rounded),
                  label: const Text('Для родителей'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KidTile extends StatelessWidget {
  const _KidTile({required this.kid, required this.onTap});

  final ChildProfile kid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.nightCard.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.purpleLight.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              ScivoRaven(avatarId: kid.avatarId, size: 96, animated: false),
              const SizedBox(height: 8),
              Text(
                kid.nickname,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                '${kid.grade} класс',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildPinScreen extends ConsumerStatefulWidget {
  const ChildPinScreen({super.key, required this.kid});

  final ChildProfile kid;

  @override
  ConsumerState<ChildPinScreen> createState() => _ChildPinScreenState();
}

class _ChildPinScreenState extends ConsumerState<ChildPinScreen> {
  String? _message;

  Future<bool> _onPin(String pin) async {
    try {
      final result =
          await ref.read(serviceProvider).verifyChildPin(widget.kid.id, pin);
      if (!mounted) return false;
      if (result.ok) {
        ref.read(activeChildProvider.notifier).state = widget.kid;
        Navigator.of(context).pop();
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
    final message = _message;

    return MagicScaffold(
      title: 'Вход',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScivoSays(
                  avatarId: widget.kid.avatarId,
                  size: 110,
                  text: 'Привет, ${widget.kid.nickname}! Введи свой секретный PIN.',
                ),
                const SizedBox(height: 20),
                PinPad(onCompleted: _onPin),
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
                const SizedBox(height: 12),
                const Text(
                  'Забыл PIN? Попроси родителя — он поможет.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

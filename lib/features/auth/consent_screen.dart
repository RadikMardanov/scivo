import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/legal/consent_text.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _loading = false;

  Future<void> _agree() async {
    setState(() => _loading = true);
    try {
      await ref.read(serviceProvider).giveConsent();
      ref.invalidate(parentProvider);
    } catch (error) {
      if (mounted) showSnack(context, friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Согласие родителя',
      showBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                const MagicCard(child: Text(kConsentFull)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _agree,
                    child: Text(_loading ? 'Сохраняю...' : 'Я согласен(на)'),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(serviceProvider).signOut(),
                  child: const Text('Выйти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

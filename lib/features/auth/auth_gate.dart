import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session;

import '../../core/errors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../family/add_child_screen.dart';
import '../family/profile_picker_screen.dart';
import '../home/child_shell.dart';
import '../parent/parent_pin_setup_screen.dart';
import 'auth_screen.dart';
import 'consent_screen.dart';

/// Решает, какой экран показать, в зависимости от состояния семьи.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Session?>>(authSessionProvider, (previous, next) {
      if (next.valueOrNull == null) {
        ref.read(activeChildProvider.notifier).state = null;
      }
    });

    final session = ref.watch(authSessionProvider);
    return session.when(
      loading: () => const SplashView(),
      error: (error, _) => _GateError(
        message: friendlyError(error),
        onRetry: () => ref.invalidate(authSessionProvider),
      ),
      data: (value) => value == null ? const AuthScreen() : const _SignedInGate(),
    );
  }
}

class _SignedInGate extends ConsumerWidget {
  const _SignedInGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentAsync = ref.watch(parentProvider);

    return parentAsync.when(
      loading: () => const SplashView(),
      error: (error, _) => _GateError(
        message: friendlyError(error),
        onRetry: () => ref.invalidate(parentProvider),
      ),
      data: (parent) {
        if (parent == null) {
          return _GateError(
            message: 'Профиль родителя не найден. Выйдите и войдите снова.',
            onRetry: () => ref.invalidate(parentProvider),
          );
        }
        if (!parent.hasConsent) return const ConsentScreen();
        if (!parent.hasPin) return const ParentPinSetupScreen();

        final childrenAsync = ref.watch(childrenProvider);
        return childrenAsync.when(
          loading: () => const SplashView(),
          error: (error, _) => _GateError(
            message: friendlyError(error),
            onRetry: () => ref.invalidate(childrenProvider),
          ),
          data: (kids) {
            if (kids.isEmpty) return const AddChildScreen(isFirst: true);
            final active = ref.watch(activeChildProvider);
            if (active != null) return ChildShell(kid: active);
            return ProfilePickerScreen(kids: kids);
          },
        );
      },
    );
  }
}

class _GateError extends ConsumerWidget {
  const _GateError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: MagicBackground(
        child: SafeArea(
          child: ErrorView(
            message: message,
            onRetry: onRetry,
            extra: TextButton(
              onPressed: () => ref.read(serviceProvider).signOut(),
              child: const Text('Выйти из аккаунта'),
            ),
          ),
        ),
      ),
    );
  }
}

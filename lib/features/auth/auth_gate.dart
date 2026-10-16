import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../family/profile_picker.dart';
import '../home/child_shell.dart';
import '../parent/parent_zone.dart';
import 'auth_screen.dart';
import 'consent_screen.dart';

/// Маршрутизатор верхнего уровня: решает, какой экран показать в зависимости
/// от состояния авторизации, согласия родителя и наличия активного героя.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final parentAsync = ref.watch(parentProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final activeKid = ref.watch(activeChildProvider);

    // Не авторизован → экран входа/регистрации.
    if (session == null) return const AuthScreen();

    // Авторизован, но согласие ещё не дано → экран согласия.
    final parent = parentAsync.valueOrNull;
    if (parent != null && !parent.hasConsent) return const ConsentScreen();

    // Согласие есть, но детей ещё нет → экран добавления первого героя.
    final kids = childrenAsync.valueOrNull ?? const [];
    if (kids.isEmpty) return const ProfilePicker(isFirstTime: true);

    // Дети есть, активный выбран → домашний шелтер ребёнка.
    if (activeKid != null) return const ChildShell();

    // Дети есть, но никто не выбран → пикер героев.
    return const ProfilePicker();
  }
}

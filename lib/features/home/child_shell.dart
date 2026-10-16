import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'wishlist_tab.dart';

/// Каркас приложения ребёнка: шапка с валютами + нижняя навигация (3 таба).
class ChildShell extends ConsumerStatefulWidget {
  const ChildShell({super.key});

  @override
  ConsumerState<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends ConsumerState<ChildShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final kid = ref.watch(activeChildProvider);
    if (kid == null) return const Center(child: CircularProgressIndicator());

    final progressAsync = ref.watch(progressProvider(kid.id));

    return MagicScaffold(
      title: '',
      showHeader: true,
      headerTrailing: progressAsync.maybeWhen(
        data: (p) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CurrencyChip(icon: Icons.feather_rounded, value: p.feathers),
            const SizedBox(width: 8),
            CurrencyChip(icon: Icons.auto_awesome_rounded, value: p.mana),
            const SizedBox(width: 8),
            CurrencyChip(icon: Icons.local_fire_department_rounded, value: p.streakDays),
          ],
        ),
        orElse: () => const SizedBox.shrink(),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeTab(kid: kid, progressAsync: progressAsync),
          WishlistTab(kid: kid),
          // ИСПРАВЛЕНО: ProfileTab теперь сам читает kid/progress через провайдеры,
          // поэтому вызываем без аргументов.
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.nightCard,
        indicatorColor: AppColors.purpleLight.withValues(alpha: 0.4),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Игры',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard_rounded),
            label: 'Вишлист',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

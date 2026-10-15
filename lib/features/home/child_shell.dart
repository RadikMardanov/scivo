import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';
import '../onboarding/onboarding_screen.dart';
import 'profile_tab.dart';
import 'wishlist_tab.dart';
import 'world_map_tab.dart';

/// Главный экран ребёнка: онбординг (1 раз) -> ежедневный бонус -> вкладки.
class ChildShell extends ConsumerStatefulWidget {
  const ChildShell({super.key, required this.kid});

  final ChildProfile kid;

  @override
  ConsumerState<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends ConsumerState<ChildShell> {
  late bool _onboarded = widget.kid.onboardingDone;
  bool _checkinStarted = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    if (_onboarded) _scheduleCheckin();
  }

  void _scheduleCheckin() {
    if (_checkinStarted) return;
    _checkinStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkin());
  }

  Future<void> _checkin() async {
    final kidId = widget.kid.id;
    try {
      final result = await ref.read(serviceProvider).checkin(kidId);
      if (!mounted) return;
      ref.invalidate(progressProvider(kidId));
      if (result.manaBonus > 0) {
        final days = result.progress.streakDays;
        final freeze = result.usedFreeze ? '\nЗаморозка спасла твою серию! ❄️' : '';
        await showScivoDialog(
          context,
          text: 'С возвращением, ${widget.kid.nickname}!\n'
              'Ежедневный бонус: +${result.manaBonus} ✨\n'
              'Серия: $days ${pluralRu(days, 'день', 'дня', 'дней')} 🔥$freeze',
          button: 'Ура!',
        );
      }
    } catch (error) {
      if (mounted) showSnack(context, friendlyError(error));
    }
  }

  void _onOnboardingFinished(int bonus) {
    setState(() => _onboarded = true);
    ref.read(activeChildProvider.notifier).state =
        widget.kid.copyWith(onboardingDone: true);
    ref.invalidate(childrenProvider);
    ref.invalidate(progressProvider(widget.kid.id));
    _scheduleCheckin();
  }

  @override
  Widget build(BuildContext context) {
    final kid = widget.kid;
    if (!_onboarded) {
      return OnboardingScreen(kid: kid, onFinished: _onOnboardingFinished);
    }

    final progress = ref.watch(progressProvider(kid.id)).valueOrNull;

    return Scaffold(
      body: MagicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(kid: kid, progress: progress),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    WorldMapTab(kid: kid),
                    WishlistTab(kid: kid, progress: progress),
                    ProfileTab(kid: kid, progress: progress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.nightCard,
        indicatorColor: AppColors.purple,
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          if (index == 1) ref.invalidate(wishlistProvider);
          if (index != 0) ref.invalidate(progressProvider(kid.id));
          setState(() => _tab = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_rounded), label: 'Игры'),
          NavigationDestination(icon: Icon(Icons.card_giftcard_rounded), label: 'Вишлист'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.kid, required this.progress});

  final ChildProfile kid;
  final ChildProgress? progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    String show(int? value) => value == null ? '…' : '$value';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          ScivoRaven(avatarId: kid.avatarId, size: 44, animated: false),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kid.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          CurrencyChip(emoji: '🪶', value: show(p?.availableFeathers)),
          const SizedBox(width: 6),
          CurrencyChip(emoji: '✨', value: show(p?.mana), color: AppColors.purpleLight),
          const SizedBox(width: 6),
          CurrencyChip(emoji: '🔥', value: show(p?.streakDays), color: AppColors.flame),
        ],
      ),
    );
  }
}

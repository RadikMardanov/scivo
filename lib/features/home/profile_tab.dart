import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';
import '../parent/parent_gate_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key, required this.kid, required this.progress});

  final ChildProfile kid;
  final ChildProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = progress;
    String show(int? value) => value == null ? '…' : '$value';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: ScivoRaven(avatarId: kid.avatarId, size: 130)),
        Center(
          child: Text(
            kid.nickname,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
        ),
        Center(
          child: Text('${kid.grade} класс', style: const TextStyle(color: Colors.white70)),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _StatTile(emoji: '🪶', value: show(p?.availableFeathers), label: 'Перья'),
            _StatTile(emoji: '✨', value: show(p?.mana), label: 'Мана'),
            _StatTile(emoji: '🔥', value: show(p?.streakDays), label: 'Дней подряд'),
            _StatTile(emoji: '❄️', value: show(p?.streakFreezes), label: 'Заморозки серии'),
            _StatTile(emoji: '⭐', value: show(p?.xp), label: 'Опыт'),
          ],
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => ref.read(activeChildProvider.notifier).state = null,
          icon: const Icon(Icons.swap_horiz_rounded),
          label: const Text('Сменить героя'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ParentGateScreen()),
          ),
          icon: const Icon(Icons.lock_rounded),
          label: const Text('Для родителей'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.emoji, required this.value, required this.label});

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: MagicCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

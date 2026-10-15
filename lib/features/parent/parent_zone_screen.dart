import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';
import '../family/add_child_screen.dart';

class ParentZoneScreen extends ConsumerWidget {
  const ParentZoneScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.nightCard,
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Чтобы снова войти, понадобятся email и пароль родителя.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final service = ref.read(serviceProvider);
    final activeChild = ref.read(activeChildProvider.notifier);
    Navigator.of(context).popUntil((route) => route.isFirst);
    activeChild.state = null;
    await service.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final parent = ref.watch(parentProvider).valueOrNull;
    final childrenAsync = ref.watch(childrenProvider);
    final name = parent?.displayName ?? '';

    return MagicScaffold(
      title: 'Родительская зона',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            name.isNotEmpty ? 'Здравствуйте, $name!' : 'Здравствуйте!',
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text('Герои семьи', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...childrenAsync.when<List<Widget>>(
            loading: () => [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [
              ErrorView(
                message: friendlyError(error),
                onRetry: () => ref.invalidate(childrenProvider),
              ),
            ],
            data: (kids) => [
              for (final kid in kids)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KidCard(kid: kid),
                ),
            ],
          ),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddChildScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить героя'),
          ),
          const SizedBox(height: 24),
          MagicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Скоро в этой зоне',
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  '📊 График занятий и слабые темы\n'
                  '🎁 Вишлист: призы за перья и подтверждение выдачи\n'
                  '⚙️ Лимит перьев в день, смена PIN, сброс PIN ребёнка\n'
                  '📧 Уведомления на email',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Выйти из аккаунта'),
          ),
        ],
      ),
    );
  }
}

class _KidCard extends ConsumerWidget {
  const _KidCard({required this.kid});

  final ChildProfile kid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider(kid.id)).valueOrNull;
    String show(int? value) => value == null ? '…' : '$value';

    return MagicCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ScivoRaven(avatarId: kid.avatarId, size: 64, animated: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kid.nickname,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text('${kid.grade} класс', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    CurrencyChip(emoji: '🪶', value: show(progress?.availableFeathers)),
                    CurrencyChip(
                      emoji: '✨',
                      value: show(progress?.mana),
                      color: AppColors.purpleLight,
                    ),
                    CurrencyChip(
                      emoji: '🔥',
                      value: show(progress?.streakDays),
                      color: AppColors.flame,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

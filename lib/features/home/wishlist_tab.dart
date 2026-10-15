import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';

/// Призы от родителей. Обмен перьев появится на этапе 5.
class WishlistTab extends ConsumerWidget {
  const WishlistTab({super.key, required this.kid, required this.progress});

  final ChildProfile kid;
  final ChildProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wishlistProvider);
    final have = progress?.availableFeathers ?? 0;

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(
        message: friendlyError(error),
        onRetry: () => ref.invalidate(wishlistProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ScivoSays(
                size: 120,
                avatarId: kid.avatarId,
                text: 'Здесь будут призы за перья 🪶. Попроси родителей '
                    'добавить их в родительской зоне!',
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(wishlistProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Мои перья: $have 🪶',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PrizeCard(item: item, have: have),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({required this.item, required this.have});

  final WishlistItem item;
  final int have;

  @override
  Widget build(BuildContext context) {
    final cost = item.featherCost;
    final ratio = cost <= 0 ? 1.0 : (have / cost).clamp(0.0, 1.0);
    final enough = have >= cost;
    final left = cost - have;

    return MagicCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text('$cost 🪶', style: const TextStyle(color: AppColors.gold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: Colors.white12,
                    color: enough ? AppColors.success : AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  enough
                      ? 'Перьев хватает! Обмен появится совсем скоро 🎉'
                      : 'Ещё $left ${pluralRu(left, 'перо', 'пера', 'перьев')}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

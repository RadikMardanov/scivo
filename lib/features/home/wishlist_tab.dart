import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';

/// Вкладка вишлиста: список желаний от родителя с эмодзи, названием и ценой.
class WishlistTab extends ConsumerWidget {
  const WishlistTab({super.key, required this.kid, required this.progress});
  final ChildProfile kid;
  final ChildProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistProvider).valueOrNull ?? const <WishlistItem>[];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: MagicCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 64, color: AppColors.purpleLight),
                const SizedBox(height: 12),
                Text('Вишлист пуст 🎁\nПопроси маму или папу добавить подарок!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.4)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final w = items[i];
        final enough = progress.feathers >= w.featherCost;
        return MagicCard(
          child: Row(
            children: [
              Text(w.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${w.featherCost} 🪶', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: enough ? AppColors.gold : Colors.white54)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: enough ? null : () {},
                child: Text(enough ? 'Есть!' : 'Хочу'),
              ),
            ],
          ),
        );
      },
    );
  }
}

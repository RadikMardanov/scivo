import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import 'add_wish_screen.dart';

/// Вкладка вишлиста с возможностью добавления желаний.
class WishlistTab extends ConsumerWidget {
  const WishlistTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);
    final kid = ref.watch(activeChildProvider);
    if (kid == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_wish_fab',
        onPressed: () async {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) => AddWishScreen(scrollController: controller),
            ),
          );
          if (added == true) ref.invalidate(wishlistProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новое желание'),
      ),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.card_giftcard_rounded, size: 80, color: AppColors.purpleLight),
                  const SizedBox(height: 16),
                  Text('Пока нет желаний', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Нажмите "+", чтобы добавить первый подарок', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _WishCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  const _WishCard({required this.item});
  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${item.featherCost} 🪶', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.gold)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border_rounded),
              tooltip: 'Запросить приз',
            ),
          ],
        ),
      ),
    );
  }
}

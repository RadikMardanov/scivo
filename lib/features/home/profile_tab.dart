import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../family/add_child_screen.dart';
import 'edit_child_screen.dart';

/// Вкладка профиля ребёнка с кнопкой редактирования.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kid = ref.watch(activeChildProvider);
    if (kid == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/art/${kid.avatarId}.png'),
                backgroundColor: AppColors.purpleLight,
              ),
              const SizedBox(height: 16),
              Text(kid.nickname, style: Theme.of(context).textTheme.headlineSmall),
              Text('${kid.grade} класс', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditChildScreen(child: kid)),
                  );
                  if (saved == true) ref.invalidate(childrenProvider);
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Редактировать профиль'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: Colors.white24),
        const SizedBox(height: 24),
        Text('Семейные герои', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...ref.watch(childrenProvider).when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Ошибка загрузки: $e'),
          data: (children) => children.map((c) => ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/art/${c.avatarId}.png'),
              backgroundColor: c.id == kid.id ? AppColors.gold : AppColors.purpleLight,
            ),
            title: Text(c.nickname),
            subtitle: Text('${c.grade} класс'),
            trailing: c.id == kid.id ? const Icon(Icons.check_circle_rounded, color: AppColors.gold) : null,
            onTap: () {
              if (c.id != kid.id) {
                ref.read(activeChildProvider.notifier).state = c;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Переключились на ${c.nickname}')),
                );
              }
            },
          )).toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) => AddChildScreen(scrollController: controller),
            ),
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Добавить нового героя'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
        ),
      ],
    );
  }
}

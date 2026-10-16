import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ИСПРАВЛЕНО: добавлен недостающий импорт AppColors.
import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';
import '../family/add_child_screen.dart';
import 'parent_gate.dart';

/// Зона управления родителем: список детей, добавление нового, настройки.
class ParentZone extends ConsumerStatefulWidget {
  const ParentZone({super.key});

  @override
  ConsumerState<ParentZone> createState() => _ParentZoneState();
}

class _ParentZoneState extends ConsumerState<ParentZone> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return ParentGate(onSuccess: () => setState(() => _unlocked = true));
    }

    final childrenAsync = ref.watch(childrenProvider);
    final parentAsync = ref.watch(parentProvider);
    final parent = parentAsync.valueOrNull;

    return MagicScaffold(
      title: 'Зона родителей',
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(childrenProvider),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: ScivoRaven(size: 80, avatarId: 'raven_blue')),
            const SizedBox(height: 16),
            Text('Привет, ${parent?.displayName ?? 'родитель'}!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text('Ваши герои', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...childrenAsync.when<List<Widget>>(
              loading: () => [const LinearProgressIndicator()],
              error: (e, _) => [Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Ошибка загрузки: $e', style: const TextStyle(color: Colors.redAccent)),
              )],
              data: (children) => children.map((c) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.purpleLight,
                  child: Text(c.nickname.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                title: Text(c.nickname),
                subtitle: Text('${c.grade} класс • 🪶${c.dailyFeatherCap}/день'),
                trailing: const Icon(Icons.edit_rounded),
                onTap: () {
                  // TODO: открыть редактирование профиля ребёнка
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const AddChildScreen()),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Добавить нового героя'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
            ),
            const SizedBox(height: 32),
            Divider(color: Colors.white24),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final service = ref.read(serviceProvider);
                await service.signOut();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}

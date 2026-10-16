import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/scivo_raven.dart';
import '../home/child_shell.dart';
import 'add_child_screen.dart';

/// Пикер героев: выбор активного ребёнка или добавление нового.
class ProfilePicker extends ConsumerWidget {
  const ProfilePicker({super.key, this.isFirstTime = false});
  final bool isFirstTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

    return MagicScaffold(
      title: isFirstTime ? 'Первый герой' : 'Кто играет?',
      showBack: !isFirstTime,
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (children) {
          if (children.isEmpty && isFirstTime) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScivoRaven(size: 120, avatarId: 'raven_blue'),
                  const SizedBox(height: 16),
                  Text('Давайте создадим первого героя!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddChildScreen(isFirst: true)),
                    ).then((_) => ref.invalidate(childrenProvider)),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Создать героя'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: ScivoRaven(size: 80, avatarId: 'raven_blue')),
              const SizedBox(height: 16),
              Text('Выберите героя', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ...children.map((c) => _ChildCard(child: c)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddChildScreen()),
                ).then((_) => ref.invalidate(childrenProvider)),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить ещё одного'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChildCard extends ConsumerStatefulWidget {
  const _ChildCard({required this.child});
  final ChildProfile child;

  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  bool _showPin = false;
  String _pin = '';
  bool _isLoading = false;

  void _onDigit(String d) {
    if (_pin.length < 4) setState(() => _pin += d);
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verifyAndEnter() async {
    if (_pin.length != 4) return;
    
    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      final result = await service.verifyChildPin(widget.child.id, _pin);
      if (result.ok) {
        ref.read(activeChildProvider.notifier).state = widget.child;
        Navigator.pushReplacement<void>(
          context,
          MaterialPageRoute(builder: (_) => const ChildShell()),
        );
      } else {
        showSnack(context, result.message, isError: true);
        setState(() => _pin = '');
      }
    } catch (e) {
      showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showPin) {
      return MagicCard(
        child: Column(
          children: [
            Text('Введите PIN для ${widget.child.nickname}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: i < _pin.length ? Colors.white : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              )),
            ),
            const SizedBox(height: 24),
            PinPad(
              onDigit: _onDigit,
              onDelete: _onDelete,
              onOk: _verifyAndEnter,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => setState(() => _showPin = false),
              child: const Text('Отмена'),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.purpleLight,
          child: Text(widget.child.nickname.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        title: Text(widget.child.nickname, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        subtitle: Text('${widget.child.grade} класс'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () => setState(() => _showPin = true),
      ),
    );
  }
}

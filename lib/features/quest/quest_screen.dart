import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/tasks.dart';
import '../../providers/app_providers.dart';
import '../../providers/quest_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';
import 'mechanics/choice_input.dart';
import 'mechanics/keypad_input.dart';
import 'task_visual.dart';

/// Экран квеста: выдаёт задачу с сервера, принимает ответ, показывает
/// подсказки и награды. Правильность решает ТОЛЬКО сервер (RPC 002).
class QuestScreen extends ConsumerStatefulWidget {
  const QuestScreen({
    super.key,
    required this.childId,
    required this.worldId,
    required this.worldTitle,
  });

  final String childId;
  final String worldId;
  final String worldTitle;

  @override
  ConsumerState<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends ConsumerState<QuestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    ref.read(questControllerProvider.notifier).reset();
    super.dispose();
  }

  void _load() =>
      ref.read(questControllerProvider.notifier).loadTask(widget.childId, widget.worldId);

  void _submit(Map<String, dynamic> input) =>
      ref.read(questControllerProvider.notifier).submit(widget.childId, input);

  void _hint() {
    final level = ref.read(questControllerProvider).hintLevel;
    ref.read(questControllerProvider.notifier).askHint(widget.childId, level + 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questControllerProvider);
    final task = state.task;
    final solved = state.lastResult?.correct == true;
    final avatarId = ref.watch(activeChildProvider)?.avatarId ?? 'raven_blue';

    Widget body;
    if (task == null) {
      body = state.error != null
          ? ErrorView(message: state.error!, onRetry: _load)
          : const Center(child: CircularProgressIndicator());
    } else {
      final supported =
          task.mechanic == Mechanics.choice || task.mechanic == Mechanics.keypad;
      body = Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                children: [
                  ScivoRaven(size: 96, avatarId: avatarId),
                  const SizedBox(height: 8),
                  SpeechBubble(_prompt(task.payload)),
                  const SizedBox(height: 16),
                  TaskVisual(payload: task.payload),
                  if (state.lastHint != null) ...[
                    const SizedBox(height: 12),
                    _HintBubble(state.lastHint!.text),
                  ],
                  if (state.lastResult != null && !solved) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Почти! Посмотри ещё раз — я рядом. 🐦‍⬛',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: solved
                ? _SolvedPanel(result: state.lastResult!, onNext: _load)
                : !supported
                    ? _UnsupportedPanel(onAnother: _load)
                    : Column(
                        children: [
                          _InputFor(
                            task: task,
                            enabled: !state.isLoading,
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  (state.isLoading || state.hintLevel >= 3) ? null : _hint,
                              icon: const Icon(Icons.lightbulb_outline_rounded),
                              label: Text('Подсказка · 5 ✨ (${state.hintLevel}/3)'),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      );
    }

    return MagicScaffold(title: widget.worldTitle, body: body);
  }

  String _prompt(Map<String, dynamic> p) {
    switch (p['kind']?.toString() ?? '') {
      case 'mul':
        return 'Кар! Умножай быстро — дракон ждёт!';
      case 'arith':
        return p['op'] == 'sub' ? 'Вычитай без страха!' : 'Складывай смелее!';
      case 'read_clock':
        return 'Посмотри на стрелки — который час?';
      case 'compare_frac':
        return 'Какая дробь больше?';
      case 'compose':
        return 'Досыпь жёлуди до кучи!';
      case 'shade_frac':
        return 'Закрась нужные дольки!';
      default:
        return 'Реши задачу, я в тебя верю!';
    }
  }
}

class _InputFor extends StatelessWidget {
  const _InputFor({required this.task, required this.enabled, required this.onSubmit});

  final GeneratedTask task;
  final bool enabled;
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  Widget build(BuildContext context) {
    if (task.mechanic == Mechanics.choice) {
      final opts =
          (task.payload['options'] as List?)?.cast<String>() ?? const <String>[];
      return ChoiceInput(options: opts, enabled: enabled, onSubmit: onSubmit);
    }
    return KeypadInput(enabled: enabled, onSubmit: onSubmit);
  }
}

class _HintBubble extends StatelessWidget {
  const _HintBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}

class _SolvedPanel extends StatelessWidget {
  const _SolvedPanel({required this.result, required this.onNext});
  final SubmitResult result;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final r = result.reward;
    final parts = <String>[];
    if (r.feather > 0) parts.add('+${r.feather} 🪶');
    if (r.mana > 0) parts.add('+${r.mana} ✨');
    if (r.xp > 0) parts.add('+${r.xp} ⭐');
    final flavor = result.feedbackKey == 'success_clean'
        ? 'Без подсказок — красавчик!'
        : 'Умница, подсказка помогла!';
    return MagicCard(
      child: Column(
        children: [
          Text(
            '🎉 Верно! ${parts.join('  ')}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.gold),
          ),
          const SizedBox(height: 6),
          Text(
            '$flavor${r.fixBonus > 0 ? '  Ты исправил ошибку — молодец!' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: onNext, child: const Text('Следующая задача')),
          ),
        ],
      ),
    );
  }
}

class _UnsupportedPanel extends StatelessWidget {
  const _UnsupportedPanel({required this.onAnother});
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) => MagicCard(
        child: Column(
          children: [
            const Text('🛠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text(
              'Этот тип задания достраивают гномы. Давай другой!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: onAnother, child: const Text('Другая задача')),
            ),
          ],
        ),
      );
}

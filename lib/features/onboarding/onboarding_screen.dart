import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';

/// История-знакомство со Scivo. Показывается ребёнку один раз (+20 маны).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.kid,
    required this.onFinished,
  });

  final ChildProfile kid;
  final void Function(int manaBonus) onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  const _Slide(this.emoji, this.text);

  final String emoji;
  final String text;
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _index = 0;
  bool _sparked = false;
  bool _saving = false;
  String? _error;

  List<_Slide> get _slides => [
        _Slide(
          '📚',
          'Привет, ${widget.kid.nickname}! Я Scivo — вороненок-хранитель '
              'Библиотеки Чисел.',
        ),
        const _Slide(
          '🌀',
          'Беда! Хаос рассыпал магию чисел по пяти островам. Без неё часы '
              'останавливаются, а мосты рушатся.',
        ),
        const _Slide(
          '✨',
          'За каждое задание ты получаешь ману. Мана — это магия: на неё можно '
              'купить подсказку или наряд для меня!',
        ),
        const _Slide(
          '🪶',
          'А перья — особенные! Их дают за задания без подсказок и победу над '
              'боссом. Перья можно обменять на настоящие призы от родителей!',
        ),
        const _Slide(
          '⚡',
          'Нажми на меня, чтобы подарить мне первую искру знаний!',
        ),
      ];

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bonus =
          await ref.read(serviceProvider).completeOnboarding(widget.kid.id);
      if (!mounted) return;
      widget.onFinished(bonus);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(error);
        });
      }
    }
  }

  void _next() {
    setState(() => _index = _index + 1);
  }

  void _spark() {
    setState(() => _sparked = true);
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    final slide = slides[_index];
    final error = _error;

    VoidCallback? mainAction;
    String mainLabel;
    if (_saving) {
      mainAction = null;
      mainLabel = 'Колдую...';
    } else if (!_isLast) {
      mainAction = _next;
      mainLabel = 'Дальше';
    } else if (_sparked) {
      mainAction = _finish;
      mainLabel = 'Начать приключение!';
    } else {
      mainAction = null;
      mainLabel = 'Нажми на Scivo ☝️';
    }

    final bubbleText = _isLast && _sparked
        ? 'Ура! Я чувствую силу! Спасибо, ${widget.kid.nickname}! '
            'Вперёд, к приключениям!'
        : slide.text;

    return MagicScaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: _saving ? null : _finish,
                child: const Text('Пропустить'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLast && _sparked ? '🌟' : slide.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isLast && !_sparked ? _spark : null,
                        child: AnimatedScale(
                          scale: _sparked ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          child: ScivoRaven(size: 170, avatarId: widget.kid.avatarId),
                        ),
                      ),
                      if (_isLast && _sparked)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '+20 ✨',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: SpeechBubble(
                          bubbleText,
                          key: ValueKey('$_index-$_sparked'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 22 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: i == _index ? AppColors.gold : Colors.white30,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: mainAction, child: Text(mainLabel)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

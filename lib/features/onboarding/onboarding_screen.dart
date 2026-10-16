import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';

/// Онбординг: 5 слайдов знакомства с Scivo.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  static const _slides = [
    ('🐦⬛', 'Привет! Я Scivo', 'Твой личный волшебник математики.'),
    ('✨', 'Магия чисел', 'Каждая задача — заклинание. Решай и получай силу!'),
    ('💡', 'Подсказки Сократа', 'Если застрянешь — я подскажу шаг за шагом, без готовых ответов.'),
    ('🏆', 'Награды', 'Перья 🪶, мана ✨, опыт ⭐ — копите и обменивайте на настоящие призы!'),
    ('', 'Готов?', 'Полетели в первый мир!', ''),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    try {
      final kid = ref.read(activeChildProvider);
      if (kid != null) {
        final service = ref.read(serviceProvider);
        await service.completeOnboarding(kid.id);
      }
      ref.invalidate(childrenProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: '',
      showBack: false,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) {
                final (emoji, title, desc) = _slides[i];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 24),
                      Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      if (desc.isNotEmpty)
                        Text(desc, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ...List.generate(_slides.length, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == _currentPage ? AppColors.gold : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(child: OutlinedButton(onPressed: () => _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), child: const Text('Назад')))
                else
                  const Spacer(),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isLoading ? null : (_currentPage == _slides.length - 1 ? _finish : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
                    child: Text(_isLoading ? 'Магия...' : (_currentPage == _slides.length - 1 ? 'Начать!' : 'Далее')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

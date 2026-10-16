import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Фон с градиентом ночи + мерцающие звёзды. Оборачивает любой контент.
class MagicBackground extends StatelessWidget {
  const MagicBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppTheme.nightGradient),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _StarsPainter()),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.5);
    // Псевдослучайная раскладка звёзд (детерминированная, без Random)
    for (var i = 0; i < 40; i++) {
      final x = ((i * 97) % 100) / 100 * size.width;
      final y = ((i * 53) % 100) / 100 * size.height;
      final r = (i % 3 == 0) ? 1.8 : 1.0;
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => false;
}

/// Каркас экрана: фон + optional AppBar + body.
class MagicScaffold extends StatelessWidget {
  const MagicScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                title!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
              ),
              actions: actions,
            ),
      body: MagicBackground(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Карточка с магическим оформлением.
class MagicCard extends StatelessWidget {
  const MagicCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.purpleLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Речевой пузырь Scivo.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Компактная плашка валюты (эмодзи + число). Используется в шапке ChildShell.
class CurrencyChip extends StatelessWidget {
  const CurrencyChip({super.key, required this.emoji, required this.value});
  final String emoji;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$value',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

/// Заглушка ошибки с кнопкой повтора.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: MagicCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 56, color: AppColors.gold),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.4)),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: onRetry, child: const Text('Попробовать снова')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Диалог Scivo (заменяет AlertDialog для единообразия).
Future<void> showScivoDialog(BuildContext context,
    {required String text, String button = 'Ок'}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.nightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(button,
                style: const TextStyle(
                    color: AppColors.gold, fontWeight: FontWeight.w800))),
      ],
    ),
  );
}

/// Русская плюрализация: pluralRu(5, 'герой', 'героя', 'героев').
String pluralRu(int n, String one, String few, String many) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14)) return few;
  return many;
}

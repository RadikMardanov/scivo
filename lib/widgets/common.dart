import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'scivo_raven.dart';

/// Ночное небо со звёздами — общий фон приложения.
class MagicBackground extends StatelessWidget {
  const MagicBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.nightGradient),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _StarsPainter())),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 45; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.6 + random.nextDouble() * 1.6;
      paint.color = Colors.white.withValues(alpha: 0.15 + random.nextDouble() * 0.45);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MagicScaffold extends StatelessWidget {
  const MagicScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showBack = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final appTitle = title;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appTitle == null
          ? null
          : AppBar(
              title: Text(appTitle),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: showBack,
              actions: actions,
            ),
      body: MagicBackground(child: SafeArea(child: body)),
    );
  }
}

class MagicCard extends StatelessWidget {
  const MagicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.nightCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.purpleLight.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: child,
    );
  }
}

class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
      ),
    );
  }
}

class ScivoSays extends StatelessWidget {
  const ScivoSays({
    super.key,
    required this.text,
    this.size = 140,
    this.avatarId = 'raven_blue',
  });

  final String text;
  final double size;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScivoRaven(size: size, avatarId: avatarId),
        const SizedBox(height: 12),
        SpeechBubble(text),
      ],
    );
  }
}

class CurrencyChip extends StatelessWidget {
  const CurrencyChip({
    super.key,
    required this.emoji,
    required this.value,
    this.color = AppColors.gold,
  });

  final String emoji;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key, this.text = 'Колдую...'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ScivoRaven(size: 150),
              const SizedBox(height: 16),
              Text(text, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const SizedBox(width: 140, child: LinearProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry, this.extra});

  final String message;
  final VoidCallback? onRetry;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    final extraWidget = extra;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (retry != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: retry, child: const Text('Попробовать снова')),
            ],
            if (extraWidget != null) ...[
              const SizedBox(height: 12),
              extraWidget,
            ],
          ],
        ),
      ),
    );
  }
}

InputDecoration magicInput(String label, {IconData? icon, Widget? suffix, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.08),
    counterText: '',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.gold, width: 2),
    ),
  );
}

Future<void> showScivoDialog(
  BuildContext context, {
  required String text,
  String button = 'Понятно',
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.nightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ScivoRaven(size: 120),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(button),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
}

/// Русское склонение: pluralRu(5, 'перо', 'пера', 'перьев') -> 'перьев'.
String pluralRu(int n, String one, String few, String many) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}

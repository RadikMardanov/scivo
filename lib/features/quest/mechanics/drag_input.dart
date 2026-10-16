import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Механика «перетаскивание»: ребёнок перетаскивает предметы в корзины.
/// Для part10 реализована как тапы по ячейкам (упрощённая drag-and-drop).
class DragInput extends StatefulWidget {
  const DragInput({super.key, required this.total, required this.given, required this.enabled, required this.onSubmit});

  final int total;
  final int given;
  final bool enabled;
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  State<DragInput> createState() => _DragInputState();
}

class _DragInputState extends State<DragInput> {
  late int _rightCount;

  @override
  void initState() {
    super.initState();
    // ИСПРАВЛЕНО: начинаем с нуля, а не с правильного ответа
    _rightCount = 0;
  }

  void _tapRight(int delta) {
    if (!widget.enabled) return;
    setState(() {
      _rightCount = (_rightCount + delta).clamp(0, widget.total - widget.given);
    });
  }

  void _send() {
    if (!widget.enabled) return;
    widget.onSubmit({'right': _rightCount});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Basket(label: 'Левая (${widget.given})', count: widget.given, color: AppColors.purpleLight),
            _Basket(label: 'Правая ($_rightCount)', count: _rightCount, color: AppColors.gold),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => _tapRight(-1), icon: const Icon(Icons.remove_circle_outline_rounded)),
            const SizedBox(width: 16),
            TextButton(onPressed: _send, child: const Text('Готово ✨')),
            const SizedBox(width: 16),
            IconButton(onPressed: () => _tapRight(1), icon: const Icon(Icons.add_circle_outline_rounded)),
          ],
        ),
      ],
    );
  }
}

class _Basket extends StatelessWidget {
  const _Basket({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('$count', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

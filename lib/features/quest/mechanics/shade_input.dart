import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Механика «закрашивание долей»: пицца/круг делится на части, ребёнок тапает нужные.
class ShadeInput extends StatefulWidget {
  const ShadeInput({super.key, required this.parts, required this.need, required this.enabled, required this.onSubmit});

  final int parts;
  final int need;
  final bool enabled;
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  State<ShadeInput> createState() => _ShadeInputState();
}

class _ShadeInputState extends State<ShadeInput> {
  late Set<int> _shaded;

  @override
  void initState() {
    super.initState();
    _shaded = {};
  }

  void _toggle(int index) {
    if (!widget.enabled) return;
    setState(() {
      if (_shaded.contains(index)) {
        _shaded.remove(index);
      } else if (_shaded.length < widget.need) {
        _shaded.add(index);
      }
    });
  }

  void _send() {
    if (!widget.enabled) return;
    widget.onSubmit({'shaded': _shaded.toList()..sort()});
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parts.clamp(1, 12);
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: p <= 4 ? 2 : 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: p,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _toggle(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _shaded.contains(i) ? AppColors.gold : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _shaded.contains(i) ? AppColors.textDark : Colors.white24, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('${i + 1}', style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _shaded.contains(i) ? AppColors.textDark : Colors.white70,
                )),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Закрась ${widget.need} из $p', textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: _send, child: const Text('Ответ ✨')),
      ],
    );
  }
}

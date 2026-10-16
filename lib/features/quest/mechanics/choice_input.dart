import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Механика «выбор из вариантов»: крупные кнопки, тап = ответ.
/// Служебные значения more/less/equal показываем как символы >, <, =.
class ChoiceInput extends StatelessWidget {
  const ChoiceInput({
    super.key,
    required this.options,
    required this.enabled,
    required this.onSubmit,
  });

  final List<String> options;
  final bool enabled;
  final void Function(Map<String, dynamic>) onSubmit;

  static const _symbols = {'more': '>', 'less': '<', 'equal': '='};

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const Center(
          child: Text('Варианты загружаются…',
              style: TextStyle(color: Colors.white70)));
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final o in options)
          SizedBox(
            width: 150,
            height: 72,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.nightCard,
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: AppColors.purpleLight.withValues(alpha: 0.6), width: 2),
                textStyle:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              onPressed: enabled ? () => onSubmit({'value': o}) : null,
              child: Text(_symbols[o] ?? o),
            ),
          ),
      ],
    );
  }
}

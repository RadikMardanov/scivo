import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Крупная PIN-клавиатура (4 цифры, кнопки ≥74dp для детских пальцев).
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onDelete, required this.onOk, this.enabled = true});
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onOk;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: [
        for (final row in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final k in row)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: SizedBox(
                      width: 74,
                      height: 74,
                      child: Material(
                        color: k.isEmpty ? Colors.transparent : Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: !enabled || k.isEmpty
                              ? null
                              : k == '⌫'
                                  ? onDelete
                                  : () => onDigit(k),
                          child: Center(
                            child: Text(k,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? onOk : null,
            child: const Text('Готово ✨'),
          ),
        ),
      ],
    );
  }
}

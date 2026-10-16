import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Механика «числовая клавиатура»: крупные кнопки 0–9, дробная черта «/»,
/// стереть, «Ответ». Работает и для целых (8+5), и для дробей (3/4).
class KeypadInput extends StatefulWidget {
  const KeypadInput({super.key, required this.enabled, required this.onSubmit});

  final bool enabled;
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  State<KeypadInput> createState() => _KeypadInputState();
}

class _KeypadInputState extends State<KeypadInput> {
  String _text = '';

  void _tap(String d) {
    if (!widget.enabled) return;
    setState(() {
      if (_text.length < 8) _text += d;
    });
  }

  void _slash() {
    if (!widget.enabled) return;
    setState(() {
      if (_text.length < 8 && !_text.contains('/')) _text += '/';
    });
  }

  void _back() {
    if (!widget.enabled || _text.isEmpty) return;
    setState(() => _text = _text.substring(0, _text.length - 1));
  }

  void _send() {
    if (!widget.enabled || _text.trim().isEmpty) return;
    widget.onSubmit({'value': _text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Column(
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Text(
            _text.isEmpty ? '?' : _text,
            style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.gold,
                letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 12),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final k in row) _Key(label: k, onTap: () => _tap(k)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Key(label: '/', onTap: _slash),
              _Key(label: '0', onTap: () => _tap('0')),
              _Key(label: '⌫', onTap: _back),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.enabled ? _send : null,
            child: const Text('Ответ ✨'),
          ),
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          width: 84,
          height: 64,
          child: Material(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Center(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
          ),
        ),
      );
}

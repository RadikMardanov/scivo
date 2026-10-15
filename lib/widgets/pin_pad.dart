import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Крупная цифровая клавиатура для PIN.
/// onCompleted возвращает true (PIN принят) или false (очистить и ввести заново).
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onCompleted, this.length = 4});

  final Future<bool> Function(String pin) onCompleted;
  final int length;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';
  bool _busy = false;

  Future<void> _tapDigit(String digit) async {
    if (_busy || _pin.length >= widget.length) return;
    setState(() => _pin = _pin + digit);
    if (_pin.length < widget.length) return;

    setState(() => _busy = true);
    var ok = false;
    try {
      ok = await widget.onCompleted(_pin);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) _pin = '';
    });
  }

  void _backspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? AppColors.gold : Colors.transparent,
                  border: Border.all(color: AppColors.gold, width: 2.5),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 4,
          width: 120,
          child: _busy ? const LinearProgressIndicator() : null,
        ),
        const SizedBox(height: 8),
        for (final row in rows)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final key in row)
                Padding(
                  padding: const EdgeInsets.all(7),
                  child: key.isEmpty
                      ? const SizedBox(width: 74, height: 74)
                      : _PinKey(
                          onTap: key == '<' ? _backspace : () => _tapDigit(key),
                          child: key == '<'
                              ? const Icon(Icons.backspace_rounded, size: 28, color: Colors.white)
                              : Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Material(
        color: Colors.white.withValues(alpha: 0.10),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

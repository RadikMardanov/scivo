import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Рисует УСЛОВИЕ задачи (то, что видит ребёнок). Правильного ответа тут нет —
/// он живёт только на сервере в active_tasks.answer.
class TaskVisual extends StatelessWidget {
  const TaskVisual({super.key, required this.payload});
  final Map<String, dynamic> payload;

  int _i(dynamic v, [int d = 0]) => (v as num?)?.toInt() ?? d;
  String _s(dynamic v) => v?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    // DIAG_BRIDGE [VISUAL]: логируем то, что реально получил визуализатор.
    try {
      // ignore: avoid_print
      print('DIAG_BRIDGE [VISUAL] payload_keys=${payload.keys.toList()}');
      // ignore: avoid_print
      print('DIAG_BRIDGE [VISUAL] kind=${payload['kind']} a=${payload['a']} b=${payload['b']} op=${payload['op']}');
    } catch (_) {/* safety */}

    // Пустой payload — ранний возврат с понятной заглушкой, без «0+0=?».
    if (payload.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Задача загружается… 🐦⬛',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
        ),
      );
    }

    final kind = _s(payload['kind']);

    // Основной путь: dispatch по полю kind.
    if (kind.isNotEmpty) {
      switch (kind) {
        case 'mul':
          return _Equation('${_i(payload['a'])} × ${_i(payload['b'])}');
        case 'arith':
          final opSym = _s(payload['op']).toLowerCase() == 'sub' ? '−' : '+';
          return _Equation('${_i(payload['a'])} $opSym ${_i(payload['b'])}');
        case 'add':
          return _Equation('${_i(payload['a'])} + ${_i(payload['b'])}');
        case 'sub':
          return _Equation('${_i(payload['a'])} − ${_i(payload['b'])}');
        case 'read_clock':
          return _ClockFace(hour: _i(payload['hour']), minute: _i(payload['minute']));
        case 'compare_frac':
          return _CompareFractions(
            leftNum: _i(payload['left_num']),
            rightNum: _i(payload['right_num']),
            den: _i(payload['den'], 4),
          );
        case 'compose':
          return _ComposeHint(total: _i(payload['total'], 10), given: _i(payload['given']));
        case 'shade_frac':
          return _ShadeHint(parts: _i(payload['parts'], 8), need: _i(payload['need'], 1));
        default:
          break; // падаем в структурный fallback ниже
      }
    }

    // Структурный fallback: определяем тип по наличию полей, если kind потерян.
    if (payload.containsKey('a') && payload.containsKey('b')) {
      if (payload.containsKey('options')) {
        return _Equation('${_i(payload['a'])} × ${_i(payload['b'])}');
      }
      final opSym = _s(payload['op']).toLowerCase() == 'sub' ? '−' : '+';
      return _Equation('${_i(payload['a'])} $opSym ${_i(payload['b'])}');
    }
    if (payload.containsKey('hour') && payload.containsKey('minute')) {
      return _ClockFace(hour: _i(payload['hour']), minute: _i(payload['minute']));
    }
    if (payload.containsKey('left_num') && payload.containsKey('den')) {
      return _CompareFractions(
        leftNum: _i(payload['left_num']),
        rightNum: _i(payload['right_num']),
        den: _i(payload['den'], 4),
      );
    }
    if (payload.containsKey('total') && payload.containsKey('given')) {
      return _ComposeHint(total: _i(payload['total'], 10), given: _i(payload['given']));
    }
    if (payload.containsKey('parts') && payload.containsKey('need')) {
      return _ShadeHint(parts: _i(payload['parts'], 8), need: _i(payload['need'], 1));
    }

    // Если ничего не распознали — диагностический вывод (не бросаем исключение).
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'DEBUG: keys=${payload.keys.join(', ')}\nvalues=${payload.values.map((v) => v.toString()).join(', ')}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
      ),
    );
  }
}

class _Equation extends StatelessWidget {
  const _Equation(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    // Защита от вырожденных значений: если текст выглядит как "0 + 0" или "0 × 0",
    // это почти наверняка признак потери данных — предупреждаем в лог.
    final looksEmpty = RegExp(r'^\s*0\s*[+\-−×]\s*0\s*$').hasMatch(text);
    if (looksEmpty) {
      // ignore: avoid_print
      print('DIAG_BRIDGE [VISUAL_WARN] suspicious_zero_equation="$text"');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '$text = ?',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _ComposeHint extends StatelessWidget {
  const _ComposeHint({required this.total, required this.given});
  final int total;
  final int given;

  @override
  Widget build(BuildContext context) {
    final need = (total - given).clamp(0, total);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text('🌰 Досыпь до $total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Уже есть: $given • Нужно добавить: $need',
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _ShadeHint extends StatelessWidget {
  const _ShadeHint({required this.parts, required this.need});
  final int parts;
  final int need;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text('🍕 Закрась $need из $parts',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Доли пиццы ждут твоей магии!',
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _CompareFractions extends StatelessWidget {
  const _CompareFractions(
      {required this.leftNum, required this.rightNum, required this.den});
  final int leftNum, rightNum, den;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FracBar(filled: leftNum, parts: den, label: '$leftNum/$den'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('?',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.purpleLight)),
          ),
          _FracBar(filled: rightNum, parts: den, label: '$rightNum/$den'),
        ],
      );
}

class _FracBar extends StatelessWidget {
  const _FracBar({required this.filled, required this.parts, required this.label});
  final int filled, parts;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = parts < 1 ? 1 : parts;
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 26,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                for (var i = 0; i < p; i++)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: i < filled
                            ? AppColors.gold
                            : Colors.white.withValues(alpha: 0.12),
                        border: i < p - 1
                            ? const Border(right: BorderSide(color: Colors.black26))
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ClockFace extends StatelessWidget {
  const _ClockFace({required this.hour, required this.minute});
  final int hour, minute;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(painter: _ClockPainter(hour: hour, minute: minute)),
        ),
      );
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.hour, required this.minute});
  final int hour, minute;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = AppColors.purpleLight);
    final tick = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3;
    for (var i = 0; i < 12; i++) {
      final a = (math.pi / 6) * i;
      canvas.drawLine(
        c + Offset(math.sin(a), -math.cos(a)) * (r - 10),
        c + Offset(math.sin(a), -math.cos(a)) * r,
        tick,
      );
    }
    final hAng = (math.pi / 6) * ((hour % 12) + minute / 60);
    final mAng = (math.pi / 30) * minute;
    canvas.drawLine(
      c,
      c + Offset(math.sin(hAng), -math.cos(hAng)) * (r * 0.5),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      c,
      c + Offset(math.sin(mAng), -math.cos(mAng)) * (r * 0.78),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 6, Paint()..color = AppColors.gold);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) =>
      old.hour != hour || old.minute != minute;
}

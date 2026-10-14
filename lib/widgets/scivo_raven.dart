import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../art/raven_art.dart';

/// Анимированный Scivo: мягко парит и моргает.
class ScivoRaven extends StatefulWidget {
  const ScivoRaven({super.key, this.size = 160});

  final double size;

  @override
  State<ScivoRaven> createState() => _ScivoRavenState();
}

class _ScivoRavenState extends State<ScivoRaven>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  Timer? _blinkTimer;
  bool _eyesClosed = false;

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() => _eyesClosed = true);
      _blinkTimer = Timer(const Duration(milliseconds: 160), () {
        if (!mounted) return;
        setState(() => _eyesClosed = false);
        _scheduleBlink();
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_bob.value);
        return Transform.translate(offset: Offset(0, -8 * t), child: child);
      },
      child: SvgPicture.string(
        _eyesClosed ? RavenArt.blink : RavenArt.idle,
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}
=== END FILE ===

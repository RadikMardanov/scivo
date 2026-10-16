import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../art/raven_art.dart';

/// Анимированный воронёнок Scivo (покачивается и моргает).
class ScivoRaven extends StatefulWidget {
  const ScivoRaven({super.key, required this.size, this.avatarId = 'raven_blue', this.animated = true});
  final double size;
  final String avatarId;
  final bool animated;

  @override
  State<ScivoRaven> createState() => _ScivoRavenState();
}

class _ScivoRavenState extends State<ScivoRaven> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _blinkTimer;
  bool _blinking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    if (widget.animated) {
      _startBlinking();
    }
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      setState(() => _blinking = true);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _blinking = false);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final angle = (_controller.value - 0.5) * 0.1; // лёгкое покачивание
        return Transform.rotate(
          angle: widget.animated ? angle : 0,
          child: SvgPicture.string(
            RavenArt.svg(widget.avatarId),
            width: widget.size,
            height: widget.size,
          ),
        );
      },
    );
  }
}

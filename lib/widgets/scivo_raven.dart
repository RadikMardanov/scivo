import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../art/raven_art.dart';

/// Вороненок: парит и моргает (animated: true) или стоит неподвижно.
class ScivoRaven extends StatefulWidget {
  const ScivoRaven({
    super.key,
    this.size = 160,
    this.avatarId = 'raven_blue',
    this.animated = true,
  });

  final double size;
  final String avatarId;
  final bool animated;

  @override
  State<ScivoRaven> createState() => _ScivoRavenState();
}

class _ScivoRavenState extends State<ScivoRaven>
    with SingleTickerProviderStateMixin {
  AnimationController? _bob;
  Timer? _blinkTimer;
  bool _eyesClosed = false;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _bob = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat(reverse: true);
      _scheduleBlink();
    }
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
    _bob?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.string(
      RavenArt.svg(widget.avatarId, blink: _eyesClosed),
      width: widget.size,
      height: widget.size,
    );
    final bob = _bob;
    if (bob == null) return picture;

    return AnimatedBuilder(
      animation: bob,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(bob.value);
        return Transform.translate(offset: Offset(0, -8 * t), child: child);
      },
      child: picture,
    );
  }
}

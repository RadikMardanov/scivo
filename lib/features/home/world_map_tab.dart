import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/worlds.dart';
import '../../models/family_models.dart';
import '../../widgets/common.dart';
import '../quest/engine_quest.dart'; // ← НОВЫЙ импорт вместо quest_screen.dart

/// Карта 5 миров. Все острова доступны всем классам (R-04).
class WorldMapTab extends StatelessWidget {
  const WorldMapTab({super.key, required this.kid});
  final ChildProfile kid;

  void _open(BuildContext context, WorldInfo w) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => QuestScreen(
        childId: kid.id,
        worldId: w.id,
        worldTitle: w.title,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Center(child: SpeechBubble('Куда полетим сегодня, ${kid.nickname}?')),
        const SizedBox(height: 16),
        for (var i = 0; i < kWorlds.length; i++) ...[
          if (i > 0) const _PathDots(),
          Align(
            alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: _WorldCard(
                world: kWorlds[i],
                recommended: kWorlds[i].fitsGrade(kid.grade),
                onTap: () => _open(context, kWorlds[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PathDots extends StatelessWidget {
  const _PathDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({required this.world, required this.recommended, required this.onTap});

  final WorldInfo world;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: world.colors,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: recommended ? AppColors.gold : Colors.white24,
              width: recommended ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(world.emoji, style: const TextStyle(fontSize: 46)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(world.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(world.topic, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Badge(text: world.gradesLabel),
                        if (recommended)
                          const _Badge(text: 'Для тебя ⭐', highlight: true),
                        const _Badge(text: 'Играть ▶', highlight: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.highlight = false});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? AppColors.gold : Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: highlight ? AppColors.textDark : Colors.white,
        ),
      ),
    );
  }
}

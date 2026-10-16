import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Информация о мире (острове) на карте.
class WorldInfo {
  const WorldInfo({
    required this.id,
    required this.title,
    required this.topic,
    required this.emoji,
    required this.colors,
    required this.gradeMin,
    required this.gradeMax,
  });

  final String id;
  final String title;
  final String topic;
  final String emoji;
  final List<Color> colors;
  final int gradeMin;
  final int gradeMax;

  bool fitsGrade(int grade) => grade >= gradeMin && grade <= gradeMax;

  String get gradesLabel => gradeMin == gradeMax
      ? '$gradeMin класс'
      : '$gradeMin–$gradeMax класс';
}

/// Все пять миров этапа 3.
const kWorlds = <WorldInfo>[
  WorldInfo(
    id: 'forest',
    title: 'Лес Счёта',
    topic: 'Состав числа, счёт до 20',
    emoji: '🌲',
    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    gradeMin: 1,
    gradeMax: 2,
  ),
  WorldInfo(
    id: 'bridge',
    title: 'Мост Чисел',
    topic: 'Сложение и вычитание до 100',
    emoji: '🌉',
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    gradeMin: 1,
    gradeMax: 2,
  ),
  WorldInfo(
    id: 'cave',
    title: 'Пещера Умножения',
    topic: 'Таблица умножения',
    emoji: '🐉',
    colors: [Color(0xFFC62828), Color(0xFFEF5350)],
    gradeMin: 2,
    gradeMax: 3,
  ),
  WorldInfo(
    id: 'clock',
    title: 'Башня Часов',
    topic: 'Чтение времени',
    emoji: '🕰️',
    colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    gradeMin: 2,
    gradeMax: 3,
  ),
  WorldInfo(
    id: 'fractions',
    title: 'Фракции Хаоса',
    topic: 'Доли и дроби',
    emoji: '🍕',
    colors: [Color(0xFFF57F17), Color(0xFFFFCA28)],
    gradeMin: 3,
    gradeMax: 4,
  ),
];

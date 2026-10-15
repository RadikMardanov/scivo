import 'package:flutter/material.dart';

class WorldInfo {
  const WorldInfo({
    required this.id,
    required this.title,
    required this.topic,
    required this.emoji,
    required this.mechanic,
    required this.minGrade,
    required this.maxGrade,
    required this.colors,
  });

  final String id;
  final String title;
  final String topic;
  final String emoji;
  final String mechanic;
  final int minGrade;
  final int maxGrade;
  final List<Color> colors;

  bool fitsGrade(int grade) => grade >= minGrade && grade <= maxGrade;

  String get gradesLabel =>
      minGrade == maxGrade ? '$minGrade класс' : '$minGrade–$maxGrade класс';
}

const List<WorldInfo> kWorlds = [
  WorldInfo(
    id: 'forest',
    title: 'Лес Счёта',
    topic: 'Состав числа, счёт до 20',
    emoji: '🌲',
    mechanic: 'Перетаскивание',
    minGrade: 1,
    maxGrade: 2,
    colors: [Color(0xFF2E8B57), Color(0xFF1F5E4A)],
  ),
  WorldInfo(
    id: 'bridge',
    title: 'Мост Чисел',
    topic: 'Сложение и вычитание до 100',
    emoji: '🌉',
    mechanic: 'Числовая прямая',
    minGrade: 1,
    maxGrade: 2,
    colors: [Color(0xFF3A7BD5), Color(0xFF2A4E9B)],
  ),
  WorldInfo(
    id: 'cave',
    title: 'Пещера Умножения',
    topic: 'Таблица умножения',
    emoji: '🐉',
    mechanic: 'Голос и босс-дракон',
    minGrade: 2,
    maxGrade: 3,
    colors: [Color(0xFFD9534F), Color(0xFF8E2C48)],
  ),
  WorldInfo(
    id: 'clock',
    title: 'Башня Часов',
    topic: 'Время и часы',
    emoji: '⏰',
    mechanic: 'Стрелки часов',
    minGrade: 2,
    maxGrade: 3,
    colors: [Color(0xFFE0A030), Color(0xFF9A5B13)],
  ),
  WorldInfo(
    id: 'fractions',
    title: 'Фракции Хаоса',
    topic: 'Доли: половина, четверть, треть',
    emoji: '🌀',
    mechanic: 'Закрашивание долей',
    minGrade: 3,
    maxGrade: 4,
    colors: [Color(0xFF8E5BE8), Color(0xFF4B2E83)],
  ),
];

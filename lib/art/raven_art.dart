import 'package:flutter/widgets.dart';

/// SVG-ассеты воронов Scivo (6 цветов аватара).
/// Кэшируем строки, чтобы не парсить каждый кадр.
class RavenArt {
  static final Map<String, String> _cache = {};

  static String svg(String avatarId) {
    if (_cache.containsKey(avatarId)) return _cache[avatarId]!;
    
    // Здесь должны быть реальные SVG-строки для каждого аватара.
    // Для демонстрации используем placeholder.
    const placeholders = {
      'raven_blue': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#4A90D9"/></svg>',
      'raven_green': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#4CAF50"/></svg>',
      'raven_red': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#F44336"/></svg>',
      'raven_yellow': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#FFEB3B"/></svg>',
      'raven_purple': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#9C27B0"/></svg>',
      'raven_black': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#212121"/></svg>',
    };
    
    final result = placeholders[avatarId] ?? placeholders['raven_blue']!;
    _cache[avatarId] = result;
    return result;
  }
}

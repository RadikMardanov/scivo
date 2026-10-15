/// Векторный вороненок Scivo (роль: Иллюстратор). Версия 0.2.
/// Аватары детей — тот же вороненок в разных цветах оперения.
class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.label,
    required this.body,
    required this.belly,
    required this.wing,
  });

  final String id;
  final String label;
  final String body;
  final String belly;
  final String wing;
}

class RavenArt {
  RavenArt._();

  static const List<AvatarOption> avatars = [
    AvatarOption(id: 'raven_blue', label: 'Синий', body: '#2B2E5C', belly: '#454A8F', wing: '#1E2147'),
    AvatarOption(id: 'raven_purple', label: 'Фиолетовый', body: '#4B2E83', belly: '#7A5BC7', wing: '#36205F'),
    AvatarOption(id: 'raven_green', label: 'Изумрудный', body: '#1F5E4A', belly: '#3E9A7A', wing: '#154235'),
    AvatarOption(id: 'raven_pink', label: 'Розовый', body: '#8A3A6E', belly: '#C46BA3', wing: '#652A50'),
    AvatarOption(id: 'raven_orange', label: 'Огненный', body: '#8A4B1E', belly: '#C9803F', wing: '#653515'),
    AvatarOption(id: 'raven_teal', label: 'Морской', body: '#1E5A6E', belly: '#3E95AE', wing: '#154050'),
  ];

  static AvatarOption avatar(String id) {
    for (final option in avatars) {
      if (option.id == id) return option;
    }
    return avatars.first;
  }

  static final Map<String, String> _cache = {};

  static String svg(String avatarId, {bool blink = false}) {
    final key = '$avatarId|$blink';
    return _cache.putIfAbsent(key, () {
      final a = avatar(avatarId);
      return _template
          .replaceAll('%%BODY%%', a.body)
          .replaceAll('%%BELLY%%', a.belly)
          .replaceAll('%%WING%%', a.wing)
          .replaceAll('%%EYES%%', blink ? _eyesClosed : _eyesOpen);
    });
  }

  static const String _template = r'''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <ellipse cx="100" cy="192" rx="46" ry="6" fill="#000000" fill-opacity="0.25"/>
  <path d="M84 168 L100 196 L116 168 Z" fill="%%WING%%"/>
  <path d="M86 176 L80 190 M86 176 L90 190" stroke="#FFB020" stroke-width="5" stroke-linecap="round" fill="none"/>
  <path d="M114 176 L110 190 M114 176 L120 190" stroke="#FFB020" stroke-width="5" stroke-linecap="round" fill="none"/>
  <ellipse cx="100" cy="128" rx="54" ry="56" fill="%%BODY%%"/>
  <ellipse cx="100" cy="140" rx="32" ry="36" fill="%%BELLY%%"/>
  <path d="M50 112 Q26 142 52 170 Q70 152 70 122 Z" fill="%%WING%%"/>
  <path d="M150 112 Q174 142 148 170 Q130 152 130 122 Z" fill="%%WING%%"/>
  <circle cx="100" cy="72" r="44" fill="%%BODY%%"/>
  <path d="M100 30 Q90 12 102 2 Q114 16 100 30 Z" fill="#FFD700"/>
  <path d="M100 30 L101 12" stroke="#E0A800" stroke-width="2" stroke-linecap="round" fill="none"/>
  <circle cx="72" cy="88" r="7" fill="#FF8FB1" fill-opacity="0.55"/>
  <circle cx="128" cy="88" r="7" fill="#FF8FB1" fill-opacity="0.55"/>
  %%EYES%%
  <path d="M71 50 Q83 46 95 51" stroke="#12142E" stroke-width="4" fill="none" stroke-linecap="round"/>
  <path d="M105 48 Q117 40 129 47" stroke="#12142E" stroke-width="4" fill="none" stroke-linecap="round"/>
  <path d="M90 84 L110 84 L100 100 Z" fill="#FFB020"/>
  <path d="M90 84 L110 84 L100 90 Z" fill="#FFCC4D"/>
</svg>
''';

  static const String _eyesOpen = '''
  <circle cx="84" cy="68" r="13" fill="#FFFFFF"/>
  <circle cx="116" cy="68" r="13" fill="#FFFFFF"/>
  <circle cx="86" cy="70" r="7" fill="#12142E"/>
  <circle cx="118" cy="70" r="7" fill="#12142E"/>
  <circle cx="88.5" cy="67" r="2.5" fill="#FFFFFF"/>
  <circle cx="120.5" cy="67" r="2.5" fill="#FFFFFF"/>
''';

  static const String _eyesClosed = '''
  <path d="M72 70 Q84 78 96 70" stroke="#FFFFFF" stroke-width="4" fill="none" stroke-linecap="round"/>
  <path d="M104 70 Q116 78 128 70" stroke="#FFFFFF" stroke-width="4" fill="none" stroke-linecap="round"/>
''';
}

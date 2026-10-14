/// Векторный вороненок Scivo (роль: Иллюстратор). Версия 0.1.
/// Слои: tail, body, wing_left, wing_right, head, eyes, beak.
/// Слоты для косметики (шляпа, плащ) добавятся на этапе 3.
class RavenArt {
  RavenArt._();

  static const String _template = r'''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <ellipse cx="100" cy="192" rx="46" ry="6" fill="#000000" fill-opacity="0.25"/>
  <path d="M84 168 L100 196 L116 168 Z" fill="#1E2147"/>
  <path d="M86 176 L80 190 M86 176 L90 190" stroke="#FFB020" stroke-width="5" stroke-linecap="round" fill="none"/>
  <path d="M114 176 L110 190 M114 176 L120 190" stroke="#FFB020" stroke-width="5" stroke-linecap="round" fill="none"/>
  <ellipse cx="100" cy="128" rx="54" ry="56" fill="#2B2E5C"/>
  <ellipse cx="100" cy="140" rx="32" ry="36" fill="#454A8F"/>
  <path d="M50 112 Q26 142 52 170 Q70 152 70 122 Z" fill="#1E2147"/>
  <path d="M150 112 Q174 142 148 170 Q130 152 130 122 Z" fill="#1E2147"/>
  <circle cx="100" cy="72" r="44" fill="#2B2E5C"/>
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

  static final String idle = _template.replaceAll('%%EYES%%', _eyesOpen);
  static final String blink = _template.replaceAll('%%EYES%%', _eyesClosed);
}

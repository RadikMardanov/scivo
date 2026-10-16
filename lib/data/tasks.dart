/// Модели заданий этапа 3. Соответствуют RPC миграции 002.
/// Ответ (answer) на клиент НЕ приходит — его знает только сервер.
class Mechanics {
  Mechanics._();
  static const choice = 'choice';
  static const keypad = 'keypad';
  static const drag = 'drag';
  static const shade = 'shade';
}

/// Задача, выданная сервером (generate_task).
class GeneratedTask {
  const GeneratedTask({
    required this.taskId,
    required this.worldId,
    required this.mechanic,
    required this.difficulty,
    required this.payload,
  });

  final String taskId;
  final String worldId;
  final String mechanic;
  final int difficulty;
  final Map<String, dynamic> payload;

  factory GeneratedTask.fromJson(Map<String, dynamic> json) {
    // DIAG_BRIDGE [PARSER]: логируем сырой ответ сервера перед парсингом.
    try {
      // ignore: avoid_print
      print('DIAG_BRIDGE [PARSER] raw_json_keys=${json.keys.toList()}');
      // ignore: avoid_print
      print('DIAG_BRIDGE [PARSER] raw_payload_type=${json['payload'].runtimeType}');
      // ignore: avoid_print
      print('DIAG_BRIDGE [PARSER] raw_payload_value=${json['payload']}');
    } catch (_) {/* safety */}

    // ИСПРАВЛЕНО (R-05): надёжное извлечение payload.
    // Supabase может вернуть payload как Map<dynamic,dynamic>, LinkedHashMap,
    // _JsonMap или даже null при ошибке десериализации. Приводим ко всему,
    // что похоже на словарь, иначе — пустой map.
    Map<String, dynamic> safePayload;
    final raw = json['payload'];
    if (raw is Map) {
      safePayload = Map<String, dynamic>.from(raw);
    } else if (raw is String && raw.isNotEmpty) {
      // На случай двойного JSON-кодирования (редко, но бывает).
      try {
        final decoded = Uri.decodeComponent(raw);
        safePayload = <String, dynamic>{'__raw_string__': decoded};
      } catch (_) {
        safePayload = <String, dynamic>{'__raw_string__': raw};
      }
    } else {
      safePayload = <String, dynamic>{};
    }

    // DIAG_BRIDGE [PARSER]: логируем итоговый payload после приведения.
    try {
      // ignore: avoid_print
      print('DIAG_BRIDGE [PARSER] parsed_payload_keys=${safePayload.keys.toList()}');
      // ignore: avoid_print
      print('DIAG_BRIDGE [PARSER] parsed_payload=$safePayload');
    } catch (_) {/* safety */}

    return GeneratedTask(
      taskId: json['task_id']?.toString() ?? '',
      worldId: json['world_id']?.toString() ?? '',
      mechanic: json['mechanic']?.toString() ?? Mechanics.keypad,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      payload: safePayload,
    );
  }
}

/// Награда за попытку (submit_answer -> reward).
class Reward {
  const Reward({
    required this.feather,
    required this.mana,
    required this.xp,
    required this.fixBonus,
  });

  final int feather;
  final int mana;
  final int xp;
  final int fixBonus;

  static const zero = Reward(feather: 0, mana: 0, xp: 0, fixBonus: 0);

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      feather: (json['feather'] as num?)?.toInt() ?? 0,
      mana: (json['mana'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      fixBonus: (json['fix_bonus'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Результат проверки ответа сервером (submit_answer).
class SubmitResult {
  const SubmitResult({
    required this.correct,
    required this.reward,
    required this.feedbackKey,
    required this.hintLevel,
  });

  final bool correct;
  final Reward reward;
  final String feedbackKey; // success_clean | success_hinted | wrong
  final int hintLevel;

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    return SubmitResult(
      correct: json['correct'] == true,
      reward: Reward.fromJson(
        Map<String, dynamic>.from(json['reward'] as Map? ?? const {}),
      ),
      feedbackKey: json['feedback_key']?.toString() ?? 'wrong',
      hintLevel: (json['hint_level'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Результат запроса подсказки (request_hint).
class HintResult {
  const HintResult({
    required this.text,
    required this.level,
    required this.manaSpent,
  });

  final String text;
  final int level;
  final int manaSpent;

  factory HintResult.fromJson(Map<String, dynamic> json) {
    final hint = json['hint'];
    final text = hint is Map
        ? (hint['text']?.toString() ?? '')
        : (hint?.toString() ?? '');
    return HintResult(
      text: text.isEmpty
          ? 'Подсказка готовится. Попробуй ещё раз, я рядом!'
          : text,
      level: (json['level'] as num?)?.toInt() ?? 0,
      manaSpent: (json['mana_spent'] as num?)?.toInt() ?? 0,
    );
  }
}

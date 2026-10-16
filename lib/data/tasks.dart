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
    return GeneratedTask(
      taskId: json['task_id'].toString(),
      worldId: json['world_id'].toString(),
      mechanic: json['mechanic'].toString(),
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      // ИСПРАВЛЕНО: читаем payload из JSON (был потерян при парсинге)
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
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

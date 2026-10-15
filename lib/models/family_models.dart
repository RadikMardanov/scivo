int _asInt(dynamic value) => (value as num?)?.toInt() ?? 0;

class ParentProfile {
  const ParentProfile({
    required this.id,
    required this.hasPin,
    required this.hasConsent,
    this.displayName,
  });

  final String id;
  final bool hasPin;
  final bool hasConsent;
  final String? displayName;

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      id: json['id'] as String,
      hasPin: json['has_pin'] == true,
      hasConsent: json['consent_at'] != null,
      displayName: json['display_name'] as String?,
    );
  }
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.nickname,
    required this.avatarId,
    required this.grade,
    required this.onboardingDone,
    required this.dailyFeatherCap,
  });

  final String id;
  final String nickname;
  final String avatarId;
  final int grade;
  final bool onboardingDone;
  final int dailyFeatherCap;

  ChildProfile copyWith({bool? onboardingDone}) {
    return ChildProfile(
      id: id,
      nickname: nickname,
      avatarId: avatarId,
      grade: grade,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      dailyFeatherCap: dailyFeatherCap,
    );
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      nickname: json['nickname'] as String? ?? 'Герой',
      avatarId: json['avatar_id'] as String? ?? 'raven_blue',
      grade: _asInt(json['grade']),
      onboardingDone: json['onboarding_done'] == true,
      dailyFeatherCap: _asInt(json['daily_feather_cap']),
    );
  }
}

class ChildProgress {
  const ChildProgress({
    required this.feathers,
    required this.feathersFrozen,
    required this.mana,
    required this.xp,
    required this.streakDays,
    required this.streakFreezes,
  });

  final int feathers;
  final int feathersFrozen;
  final int mana;
  final int xp;
  final int streakDays;
  final int streakFreezes;

  int get availableFeathers => feathers - feathersFrozen;

  static const empty = ChildProgress(
    feathers: 0,
    feathersFrozen: 0,
    mana: 0,
    xp: 0,
    streakDays: 0,
    streakFreezes: 0,
  );

  factory ChildProgress.fromJson(Map<String, dynamic> json) {
    return ChildProgress(
      feathers: _asInt(json['feathers']),
      feathersFrozen: _asInt(json['feathers_frozen']),
      mana: _asInt(json['mana']),
      xp: _asInt(json['xp']),
      streakDays: _asInt(json['streak_days']),
      streakFreezes: _asInt(json['streak_freezes']),
    );
  }
}

class CheckinResult {
  const CheckinResult({
    required this.progress,
    required this.manaBonus,
    required this.usedFreeze,
  });

  final ChildProgress progress;
  final int manaBonus;
  final bool usedFreeze;
}

class PinCheckResult {
  const PinCheckResult({
    required this.ok,
    this.reason,
    this.attemptsLeft,
    this.lockSeconds,
  });

  final bool ok;
  final String? reason;
  final int? attemptsLeft;
  final int? lockSeconds;

  factory PinCheckResult.fromJson(Map<String, dynamic> json) {
    return PinCheckResult(
      ok: json['ok'] == true,
      reason: json['reason'] as String?,
      attemptsLeft: (json['attempts_left'] as num?)?.toInt(),
      lockSeconds: (json['seconds'] as num?)?.toInt(),
    );
  }

  String get message {
    switch (reason) {
      case 'locked':
        return 'Слишком много попыток. Подождите ${lockSeconds ?? 60} сек.';
      case 'no_pin':
        return 'PIN родителя ещё не задан.';
      default:
        final left = attemptsLeft;
        if (left != null) return 'Неверный PIN. Осталось попыток: $left';
        return 'Неверный PIN.';
    }
  }
}

class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.title,
    required this.featherCost,
    required this.emoji,
  });

  final String id;
  final String title;
  final int featherCost;
  final String emoji;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Приз',
      featherCost: _asInt(json['feather_cost']),
      emoji: json['emoji'] as String? ?? '🎁',
    );
  }
}

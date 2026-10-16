import 'package:flutter/foundation.dart';

@immutable
class ParentProfile {
  const ParentProfile({
    required this.id,
    required this.displayName,
    required this.hasPin,
    required this.consentAt,
  });

  final String id;
  final String displayName;
  final bool hasPin;
  final DateTime? consentAt;

  bool get hasConsent => consentAt != null;

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      id: json['id'].toString(),
      displayName: json['display_name']?.toString() ?? '',
      hasPin: json['has_pin'] == true,
      consentAt: json['consent_at'] != null
          ? DateTime.tryParse(json['consent_at'].toString())
          : null,
    );
  }
}

@immutable
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

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'].toString(),
      nickname: json['nickname']?.toString() ?? '',
      avatarId: json['avatar_id']?.toString() ?? 'raven_blue',
      grade: (json['grade'] as num?)?.toInt() ?? 1,
      onboardingDone: json['onboarding_done'] == true,
      dailyFeatherCap: (json['daily_feather_cap'] as num?)?.toInt() ?? 5,
    );
  }
}

@immutable
class ChildProgress {
  const ChildProgress({
    required this.feathers,
    required this.mana,
    required this.xp,
    required this.streakDays,
    required this.lastCheckinDate,
  });

  final int feathers;
  final int mana;
  final int xp;
  final int streakDays;
  final DateTime? lastCheckinDate;

  static const empty = ChildProgress(
    feathers: 0,
    mana: 0,
    xp: 0,
    streakDays: 0,
    lastCheckinDate: null,
  );

  factory ChildProgress.fromJson(Map<String, dynamic> json) {
    return ChildProgress(
      feathers: (json['feathers'] as num?)?.toInt() ?? 0,
      mana: (json['mana'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      lastCheckinDate: json['last_checkin_date'] != null
          ? DateTime.tryParse(json['last_checkin_date'].toString())
          : null,
    );
  }
}

@immutable
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

@immutable
class PinCheckResult {
  const PinCheckResult({required this.ok, required this.message});

  final bool ok;
  final String message;

  factory PinCheckResult.fromJson(Map<String, dynamic> json) {
    return PinCheckResult(
      ok: json['ok'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}

@immutable
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
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      featherCost: (json['feather_cost'] as num?)?.toInt() ?? 0,
      emoji: json['emoji']?.toString() ?? '🎁',
    );
  }
}

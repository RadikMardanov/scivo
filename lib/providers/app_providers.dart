import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env_config.dart';
import '../models/family_models.dart';
import '../services/supabase_service.dart';

// --- Сервис ---
final serviceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(EnvConfig.supabase);
});

// --- Сессия аутентификации ---
final authSessionProvider = StreamProvider<Session?>((ref) {
  final service = ref.watch(serviceProvider);
  return service.authChanges.map((state) => state.session);
});

// --- Профиль родителя ---
final parentProvider = FutureProvider<ParentProfile?>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return null;
  final service = ref.read(serviceProvider);
  return service.fetchParent();
});

// --- Список детей ---
final childrenProvider = FutureProvider<List<ChildProfile>>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return [];
  final service = ref.read(serviceProvider);
  return service.fetchChildren();
});

// --- Активный ребёнок (выбранный в picker) ---
final activeChildProvider = StateProvider<ChildProfile?>((ref) => null);

// --- Прогресс конкретного ребёнка ---
final progressProvider = FamilyProvider<String, ChildProgress>((ref, childId) async {
  final service = ref.read(serviceProvider);
  return service.fetchProgress(childId);
});

// --- Вишлист ---
final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return [];
  final service = ref.read(serviceProvider);
  return service.fetchWishlist();
});

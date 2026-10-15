import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/family_models.dart';
import '../services/supabase_service.dart';

final serviceProvider = Provider<SupabaseService>(
  (ref) => SupabaseService(Supabase.instance.client),
);

/// Текущая сессия родителя (null — не вошли).
final authSessionProvider = StreamProvider<Session?>((ref) async* {
  final service = ref.watch(serviceProvider);
  yield service.currentSession;
  await for (final event in service.authChanges) {
    yield event.session;
  }
});

final parentProvider = FutureProvider.autoDispose<ParentProfile?>(
  (ref) => ref.watch(serviceProvider).fetchParent(),
);

final childrenProvider = FutureProvider.autoDispose<List<ChildProfile>>(
  (ref) => ref.watch(serviceProvider).fetchChildren(),
);

/// Ребёнок, который сейчас играет (выбран и ввёл PIN).
final activeChildProvider = StateProvider<ChildProfile?>((ref) => null);

final progressProvider = FutureProvider.autoDispose.family<ChildProgress, String>(
  (ref, childId) => ref.watch(serviceProvider).fetchProgress(childId),
);

final wishlistProvider = FutureProvider.autoDispose<List<WishlistItem>>(
  (ref) => ref.watch(serviceProvider).fetchWishlist(),
);

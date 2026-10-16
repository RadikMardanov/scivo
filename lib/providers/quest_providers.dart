import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors.dart';
import '../data/tasks.dart';
import '../services/supabase_service.dart';
import 'app_providers.dart';

/// Состояние активного квеста: одна задача + последняя проверка + подсказки.
class QuestState {
  const QuestState({
    this.task,
    this.isLoading = false,
    this.error,
    this.lastResult,
    this.hintLevel = 0,
    this.lastHint,
  });

  final GeneratedTask? task;
  final bool isLoading;
  final String? error;
  final SubmitResult? lastResult;
  final int hintLevel; // сколько подсказок уже открыто по текущей задаче
  final HintResult? lastHint;
}

class QuestController extends StateNotifier<QuestState> {
  QuestController(this._ref) : super(const QuestState());

  final Ref _ref;

  SupabaseService get _service => _ref.read(serviceProvider);

  /// Загружает новую задачу по миру (сбрасывает предыдущее состояние).
  Future<void> loadTask(String childId, String worldId) async {
    state = const QuestState(isLoading: true);
    try {
      final task = await _service.generateTask(childId, worldId);
      state = QuestState(task: task);
    } catch (error) {
      state = QuestState(error: friendlyError(error));
    }
  }

  /// Отправляет ответ; при успехе обновляет прогресс (перья/мана в шапке).
  Future<void> submit(String childId, Map<String, dynamic> input) async {
    final task = state.task;
    if (task == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.submitAnswer(childId, task.taskId, input);
      state = state.copyWith(isLoading: false, lastResult: result);
      _ref.invalidate(progressProvider(childId));
    } catch (error) {
      state = state.copyWith(isLoading: false, error: friendlyError(error));
    }
  }

  /// Запрашивает подсказку уровня 1..3 (один раз на уровень).
  Future<void> askHint(String childId, int level) async {
    final task = state.task;
    if (task == null) return;
    if (level <= state.hintLevel) return; // этот уровень уже давали
    try {
      final hint = await _service.requestHint(childId, task.taskId, level);
      state = state.copyWith(lastHint: hint, hintLevel: level);
      _ref.invalidate(progressProvider(childId)); // мана списалась
    } catch (error) {
      state = state.copyWith(error: friendlyError(error));
    }
  }

  void reset() => state = const QuestState();
}

final questControllerProvider =
    StateNotifierProvider<QuestController, QuestState>((ref) {
  return QuestController(ref);
});

extension on QuestState {
  QuestState copyWith({
    bool? isLoading,
    String? error,
    SubmitResult? lastResult,
    HintResult? lastHint,
    int? hintLevel,
    bool clearError = false,
  }) {
    return QuestState(
      task: task,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastResult: lastResult ?? this.lastResult,
      hintLevel: hintLevel ?? this.hintLevel,
      lastHint: lastHint ?? this.lastHint,
    );
  }
}

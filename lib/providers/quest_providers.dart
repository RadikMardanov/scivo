import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tasks.dart';
import '../services/supabase_service.dart';
import 'app_providers.dart';

/// Состояние экрана квеста: текущая задача, результат последней попытки,
/// уровень использованных подсказок, статус загрузки, текст ошибки.
class QuestState {
  const QuestState({
    this.task,
    this.lastResult,
    this.lastHint,
    this.hintLevel = 0,
    this.isLoading = false,
    this.error,
  });

  final GeneratedTask? task;
  final SubmitResult? lastResult;
  final HintResult? lastHint;
  final int hintLevel;
  final bool isLoading;
  final String? error;

  QuestState copyWith({
    GeneratedTask? task,
    SubmitResult? lastResult,
    HintResult? lastHint,
    int? hintLevel,
    bool? isLoading,
    String? error,
  }) {
    return QuestState(
      task: task ?? this.task,
      lastResult: lastResult ?? this.lastResult,
      lastHint: lastHint ?? this.lastHint,
      hintLevel: hintLevel ?? this.hintLevel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Контроллер квеста: вызывает RPC generate_task / submit_answer / request_hint.
class QuestController extends StateNotifier<QuestState> {
  QuestController(this._service) : super(const QuestState());

  final SupabaseService _service;

  Future<void> loadTask(String childId, String worldId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastResult: null,
      lastHint: null,
      hintLevel: 0,
    );
    try {
      final task = await _service.generateTask(childId, worldId);
      // DIAG_BRIDGE [CONTROLLER]: фиксируем момент получения задачи контроллером.
      // ignore: avoid_print
      print('DIAG_BRIDGE [CONTROLLER] loaded task_id=${task.taskId} world=${task.worldId} mech=${task.mechanic} diff=${task.difficulty}');
      // ignore: avoid_print
      print('DIAG_BRIDGE [CONTROLLER] payload_in_controller=${task.payload}');
      state = state.copyWith(task: task, isLoading: false);
    } catch (e, st) {
      // ignore: avoid_print
      print('DIAG_BRIDGE [CONTROLLER_ERROR] $e\n$st');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> submit(String childId, Map<String, dynamic> input) async {
    final task = state.task;
    if (task == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final result = await _service.submitAnswer(childId, task.taskId, input);
      state = state.copyWith(lastResult: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> askHint(String childId, int level) async {
    final task = state.task;
    if (task == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final hint = await _service.requestHint(childId, task.taskId, level);
      state = state.copyWith(lastHint: hint, hintLevel: level, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void reset() {
    state = const QuestState();
  }
}

/// Провайдер контроллера квеста.
final questControllerProvider =
    StateNotifierProvider<QuestController, QuestState>((ref) {
  final service = ref.read(serviceProvider);
  return QuestController(service);
});

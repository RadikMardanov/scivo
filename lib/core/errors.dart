import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Переводит технические ошибки в понятные фразы на русском.
String friendlyError(Object error) {
  if (error is AppException) return error.message;

  String raw;
  if (error is AuthException) {
    raw = error.message;
  } else if (error is PostgrestException) {
    raw = error.message;
  } else {
    raw = error.toString();
  }
  debugPrint('Scivo error: $raw');

  final text = raw.toLowerCase();
  const known = <String, String>{
    'invalid login credentials': 'Неверный email или пароль.',
    'user already registered': 'Этот email уже зарегистрирован. Попробуйте войти.',
    'already been registered': 'Этот email уже зарегистрирован. Попробуйте войти.',
    'password should be at least': 'Пароль должен быть не короче 6 символов.',
    'unable to validate email': 'Проверьте правильность email.',
    'invalid format': 'Проверьте правильность email.',
    'rate limit': 'Слишком много попыток. Подождите немного.',
    'pin_must_be_4_digits': 'PIN должен состоять из 4 цифр.',
    'invalid_grade': 'Выберите класс от 1 до 4.',
    'invalid_nickname': 'Имя героя — от 1 до 20 символов.',
    'too_many_children': 'В семье может быть не больше 5 героев.',
    'not_authorized': 'Нет доступа к этому профилю.',
    'child_not_found': 'Профиль ребёнка не найден.',
    'parent_not_found': 'Профиль родителя не найден. Выйдите и войдите снова.',
    'failed host lookup': 'Нет связи с интернетом.',
    'socketexception': 'Нет связи с интернетом.',
    'clientexception': 'Нет связи с сервером. Проверьте интернет.',
    'failed to fetch': 'Нет связи с сервером. Проверьте интернет.',
    'timeout': 'Сервер долго не отвечает. Попробуйте ещё раз.',
  };

  for (final entry in known.entries) {
    if (text.contains(entry.key)) return entry.value;
  }
  return 'Что-то пошло не так. Попробуйте ещё раз.';
}

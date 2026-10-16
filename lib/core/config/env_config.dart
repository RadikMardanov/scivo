import 'package:supabase_flutter/supabase_flutter.dart';

/// Конфигурация окружения. Секреты SUPABASE_URL и SUPABASE_ANON_KEY
/// передаются через --dart-define при сборке в GitHub Actions.
class EnvConfig {
  static late final SupabaseClient supabase;

  static Future<void> initSupabase() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY. Use --dart-define.');
    }
    
    await Supabase.initialize(url: url, anonKey: anonKey);
    supabase = Supabase.instance.client;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  if (!EnvConfig.isConfigured) {
    initError = 'Не заданы SUPABASE_URL и SUPABASE_ANON_KEY.';
  } else {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (error) {
      initError = error.toString();
    }
  }

  runApp(ProviderScope(child: ScivoApp(initError: initError)));
}

class ScivoApp extends StatelessWidget {
  const ScivoApp({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context) {
    final error = initError;
    return MaterialApp(
      title: 'Scivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: error == null
          ? const AuthGate()
          : Scaffold(
              body: MagicBackground(
                child: SafeArea(
                  child: ErrorView(message: 'Не удалось запустить магию: $error'),
                ),
              ),
            ),
    );
  }
}

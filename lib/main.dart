import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/config/env_config.dart';
import 'core/errors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Supabase (URL и anon key приходят через --dart-define в CI)
  await EnvConfig.initSupabase();
  
  runApp(const ProviderScope(child: ScivoApp()));
}

class ScivoApp extends StatelessWidget {
  const ScivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AuthGate(),
    );
  }
}

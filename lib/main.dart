import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'widgets/scivo_raven.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  if (EnvConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (error) {
      initError = error.toString();
    }
  } else {
    initError = 'Не заданы SUPABASE_URL и SUPABASE_ANON_KEY';
  }

  runApp(ProviderScope(child: ScivoApp(initError: initError)));
}

class ScivoApp extends StatelessWidget {
  const ScivoApp({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: MagicCheckScreen(initError: initError),
    );
  }
}

class MagicCheckScreen extends StatefulWidget {
  const MagicCheckScreen({super.key, this.initError});

  final String? initError;

  @override
  State<MagicCheckScreen> createState() => _MagicCheckScreenState();
}

class _MagicCheckScreenState extends State<MagicCheckScreen> {
  late Future<String> _

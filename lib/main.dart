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
  late Future<String> _check;

  @override
  void initState() {
    super.initState();
    _check = _runCheck();
  }

  Future<String> _runCheck() async {
    if (widget.initError != null) {
      throw Exception(widget.initError);
    }
    final row = await Supabase.instance.client
        .from('app_status')
        .select('message')
        .single()
        .timeout(const Duration(seconds: 12));
    return row['message'] as String;
  }

  void _retry() {
    setState(() {
      _check = _runCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.nightGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ScivoRaven(size: 200),
                  const SizedBox(height: 16),
                  Text(
                    'Scivo',
                    style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Магическое приключение с математикой',
                    textAlign: TextAlign.center,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  FutureBuilder<String>(
                    future: _check,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const _StatusCard(
                          icon: '🔮',
                          title: 'Проверяю магическую связь...',
                          loading: true,
                        );
                      }
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            _StatusCard(
                              icon: '⚠️',
                              title: 'Связь с сервером не установлена',
                              subtitle: snapshot.error.toString(),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _retry,
                              child: const Text('Попробовать снова'),
                            ),
                          ],
                        );
                      }
                      return _StatusCard(
                        icon: '✅',
                        title: snapshot.data ?? 'Готово',
                        subtitle: 'Сервер на связи. Фундамент построен!',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.loading = false,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nightCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.purpleLight.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: text.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          if (loading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
        ],
      ),
    );
  }
}

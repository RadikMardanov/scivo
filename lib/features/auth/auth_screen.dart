import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/legal/consent_text.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isRegister = false;
  bool _consent = false;
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;

    String? problem;
    if (!email.contains('@') || !email.contains('.')) {
      problem = 'Введите корректный email.';
    } else if (password.length < 6) {
      problem = 'Пароль — минимум 6 символов.';
    } else if (_isRegister && !_consent) {
      problem = 'Отметьте согласие на обработку данных.';
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final service = ref.read(serviceProvider);
    try {
      if (_isRegister) {
        await service.signUpParent(
          email: email,
          password: password,
          displayName: _name.text,
        );
        if (service.currentSession == null && mounted) {
          setState(() => _error =
              'Аккаунт создан. Подтвердите email по ссылке из письма и войдите.');
        }
      } else {
        await service.signIn(email, password);
      }
    } catch (error) {
      if (mounted) setState(() => _error = friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showConsent() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.nightCard,
        title: const Text('Согласие'),
        content: const SingleChildScrollView(child: Text(kConsentFull)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final error = _error;

    return MagicScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ScivoRaven(size: 140),
                Text(
                  'Scivo',
                  style: text.displaySmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Магическое приключение с математикой',
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 24),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('Вход')),
                    ButtonSegment(value: true, label: Text('Регистрация')),
                  ],
                  selected: {_isRegister},
                  onSelectionChanged: (selection) => setState(() {
                    _isRegister = selection.first;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 20),
                if (_isRegister) ...[
                  TextField(
                    controller: _name,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.words,
                    decoration: magicInput(
                      'Как к вам обращаться (необязательно)',
                      icon: Icons.person_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: magicInput('Email родителя', icon: Icons.email_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: !_showPassword,
                  onSubmitted: (_) => _submit(),
                  decoration: magicInput(
                    'Пароль',
                    icon: Icons.lock_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _consent,
                    onChanged: (value) => setState(() => _consent = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Я родитель и согласен(на) на обработку данных'),
                    subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _showConsent,
                        child: const Text('Прочитать согласие'),
                      ),
                    ),
                  ),
                ],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(
                      _loading
                          ? 'Колдую...'
                          : _isRegister
                              ? 'Создать аккаунт'
                              : 'Войти',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Аккаунт создаёт родитель. Детям email не нужен — '
                  'их профили появятся внутри вашего аккаунта.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

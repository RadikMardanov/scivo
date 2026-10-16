import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/scivo_raven.dart';

/// Экран входа/регистрации родителя.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      if (_isLogin) {
        await service.signIn(_emailController.text, _passwordController.text);
      } else {
        await service.signUpParent(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _displayNameController.text,
        );
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: _isLogin ? 'Вход в магию' : 'Новый герой',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: ScivoRaven(size: 120, avatarId: 'raven_blue')),
              const SizedBox(height: 16),
              Text(
                _isLogin ? 'Рады видеть тебя снова!' : 'Создай аккаунт родителя',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              if (!_isLogin) ...[
                TextFormField(
                  controller: _displayNameController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
                  decoration: magicInput('Как вас зовут?', icon: Icons.person_outline_rounded),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите email';
                  if (!v.contains('@')) return 'Некорректный email';
                  return null;
                },
                decoration: magicInput('Email родителя', icon: Icons.email_rounded),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите пароль';
                  if (v.length < 6) return 'Минимум 6 символов';
                  return null;
                },
                decoration: magicInput('Пароль', icon: Icons.lock_outline_rounded),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.magic_button_rounded),
                label: Text(_isLoading ? 'Магия...' : (_isLogin ? 'Войти' : 'Зарегистрироваться')),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Нет аккаунта? Создать' : 'Уже есть аккаунт? Войти',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

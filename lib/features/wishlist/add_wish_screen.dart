import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/family_models.dart';
import '../../providers/app_providers.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common.dart';

/// Экран добавления нового желания в вишлист.
class AddWishScreen extends ConsumerStatefulWidget {
  const AddWishScreen({super.key});

  @override
  ConsumerState<AddWishScreen> createState() => _AddWishScreenState();
}

class _AddWishScreenState extends ConsumerState<AddWishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  String _emoji = '🎁';
  bool _isLoading = false;

  static const _emojis = ['🎁', '🧸', '', '', '', '🎮', '🍕', '🏖️', '', ''];

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final service = ref.read(serviceProvider);
      await service.addWishlistItem(
        title: _titleController.text.trim(),
        featherCost: int.parse(_costController.text),
        emoji: _emoji,
      );
      ref.invalidate(wishlistProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Новое желание',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Название подарка:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 30,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                decoration: InputDecoration(
                  hintText: 'Например, конструктор LEGO',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Стоимость в перьях 🪶:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Укажите стоимость';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Только положительное число';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Например, 50',
                  prefixIcon: const Icon(Icons.feather_rounded),
                  suffixText: '🪶',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Эмодзи:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis.map((e) => ChoiceChip(
                  label: Text(e, style: const TextStyle(fontSize: 24)),
                  selected: _emoji == e,
                  onSelected: (_) => setState(() => _emoji = e),
                  showCheckmark: false,
                  selectedColor: AppColors.gold.withValues(alpha: 0.3),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                )).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_rounded),
                label: Text(_isLoading ? 'Добавляем...' : 'Добавить в вишлист'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

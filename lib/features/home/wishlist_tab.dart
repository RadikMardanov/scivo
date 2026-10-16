// ... (остаётся без изменений, только исправляем конструктор)
class WishlistTab extends ConsumerWidget {
  const WishlistTab({super.key, required this.kid, required this.progress});
  final ChildProfile kid;
  final ChildProgress progress;
  // ... остальной код без изменений
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado reativo dos favoritos, compartilhado entre lista, detalhe e
/// tela de favoritos. Persiste apenas os IDs em shared_preferences.
class FavoritesController extends ChangeNotifier {
  static const _kKey = 'favorite_ids';

  final Set<int> _ids = {};

  Set<int> get ids => Set.unmodifiable(_ids);

  int get count => _ids.length;

  bool isFavorite(int productId) => _ids.contains(productId);

  Future<void> toggle(int productId) async {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kKey,
      _ids.map((e) => e.toString()).toList(),
    );
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_kKey);
    if (stored != null) {
      _ids
        ..clear()
        ..addAll(stored.map(int.parse));
    }
    notifyListeners();
  }
}

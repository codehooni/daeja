import 'package:hive/hive.dart';

class SearchHistoryDatabase {
  static const String boxName = 'search_history';

  Box<String> get _box => Hive.box<String>(boxName);

  // Get last 10 searches (newest first)
  List<String> getRecentSearches() {
    return _box.values.toList().reversed.take(10).toList();
  }

  // Add search (avoid duplicates)
  void addSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Remove if exists
    final existing = _box.values.toList().indexOf(trimmed);
    if (existing >= 0) _box.deleteAt(existing);

    // Add to end (newest)
    _box.add(trimmed);
  }

  // Remove specific search
  void removeSearch(String query) {
    final values = _box.values.toList();
    final index = values.indexOf(query);
    if (index >= 0) _box.deleteAt(index);
  }

  // Clear all
  void clearAll() {
    _box.clear();
  }
}

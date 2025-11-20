import 'package:domain/value_objects/id.dart';

/// Generic base class for an in-memory database of type [TItem], keyed by [TId].
abstract class InMemoryDatabase<TId extends Id, TItem> {
  final Map<TId, TItem> _items = {};

  /// Retrieves an item by its [id].
  Future<TItem?> get(TId id) async {
    try {
      return _items[id];
    } catch (_) {
      return null;
    }
  }

  /// Returns a list of all items currently stored in the database.
  Future<List<TItem>> getAll() async => _items.values.toList();

  /// Inserts or updates an item with the given [id] and [value].
  Future<void> put(TId id, TItem value) async {
    _items[id] = value;
  }

  /// Deletes the item with the given [id] from the database.
  Future<void> delete(TId id) async {
    try {
      _items.remove(id);
    } catch (_) {
      rethrow;
    }
  }
}

import 'package:domain/value_objects/id.dart';

abstract class Database<T> {
  final Map<Id, T> _items = {};

  Future<T?> get(Id id) async {
    try {
      return _items[id];
    } catch (_) {
      return null;
    }
  }

  Future<List<T>> getAll() async => _items.values.toList();

  Future<void> put(Id id, T value) async {
    _items[id] = value;
  }

  Future<void> delete(Id id) async {
    try {
      _items.remove(id);
    } catch (_) {
      rethrow;
    }
  }
}

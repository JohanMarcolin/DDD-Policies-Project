import 'package:domain/value_objects/id.dart';

abstract class Database<T> {
  final Map<Id, T> _items = {};

  T? get(Id id) {
    try {
      return _items[id];
    } catch (_) {
      return null;
    }
  }

  List<T> getAll() => _items.values.toList();

  void put(Id id, T value) {
    _items[id] = value;
  }

  void delete(Id id) {
    try {
      _items.remove(id);
    } catch (_) {
      rethrow;
    }
  }
}

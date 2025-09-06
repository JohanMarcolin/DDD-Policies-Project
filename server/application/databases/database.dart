import '../../domain/value_objects/id.dart';

abstract class Database<T> {
  final Map<Id, T> _items = {};

  T? get(Id id) => _items[id];

  List<T> getAll() => _items.values.toList();

  void put(Id id, T value) {
    _items[id] = value;
  }

  void delete(Id id) {
    _items.remove(id);
  }
}

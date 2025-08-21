mixin InMemoryDb<T> {
  final Map<String, T> _items = {};

  T? get(String id) => _items[id];

  List<T> getAll() => _items.values.toList();

  void put(String id, T value) {
    _items[id] = value;
  }

  void delete(String id) {
    _items.remove(id);
  }
}
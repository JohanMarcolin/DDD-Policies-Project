/// An asynchronous in-memory key-value database.
///
/// Stores values of type [TValue] indexed by keys of type [TKey].
base class InMemoryDatabase<TKey, TValue> {
  final Map<TKey, TValue> _map = {};

  /// Provides direct access to the underlying map.
  Map<TKey, TValue> get map => _map;

  /// Retrieves the value associated with [key], or `null` if not found.
  ///
  /// Rethrows any unexpected errors.
  Future<TValue?> get(TKey key) async {
    try {
      return _map[key];
    } catch (_) {
      rethrow;
    }
  }

  /// Returns a list of all values currently stored in the map.
  Future<List<TValue>> getAll() async => _map.values.toList();

  /// Inserts or updates the [value] for the given [key].
  ///
  /// Overwrites any existing value for [key].
  Future<void> put(TKey key, TValue value) async {
    _map[key] = value;
  }

  /// Deletes the value associated with [key], if it exists.
  ///
  /// Rethrows any unexpected errors.
  Future<void> delete(TKey key) async {
    try {
      _map.remove(key);
    } catch (_) {
      rethrow;
    }
  }
}

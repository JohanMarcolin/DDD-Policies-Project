import 'package:flutter_test/flutter_test.dart';

/// Extension methods for [Finder] to simplify widget tree traversal in tests.
///
/// Provides methods to find descendant widgets of a specific type or matching criteria.
extension WidgetFinderExtension on Finder {
  Finder findDescendant(Type component) {
    return find.descendant(of: this, matching: find.byType(component));
  }

  Finder findDescendantMatching(Finder matching) {
    return find.descendant(of: this, matching: matching);
  }
}

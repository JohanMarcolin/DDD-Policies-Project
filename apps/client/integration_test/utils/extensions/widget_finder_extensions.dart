import 'package:flutter_test/flutter_test.dart';

/// Extension methods for [Finder] to simplify widget tree traversal in tests.
///
/// These methods help locate widgets within the widget tree based on type or criteria.
extension WidgetFinderExtension on Finder {
  /// Finds widgets of the specified [Type] that are descendants of this [Finder].
  ///
  /// Example:
  /// ```dart
  /// final submitButtonFinder = find.byType(Form).findDescendant(SubmitButton);
  /// ```
  ///
  /// - [component]: The type of widget to find.
  /// - Returns: A [Finder] for the matching descendant widgets.
  Finder findDescendant(Type component) {
    return find.descendant(of: this, matching: find.byType(component));
  }

  /// Finds widgets matching the given [Finder] that are descendants of this [Finder].
  ///
  /// Example:
  /// ```dart
  /// final submitButtonFinder = find.byType(Form).findDescendantMatching(find.text('Submit'));
  /// ```
  ///
  /// - [matching]: The [Finder] to match descendant widgets.
  /// - Returns: A [Finder] for the matching descendant widgets.
  Finder findDescendantMatching(Finder matching) {
    return find.descendant(of: this, matching: matching);
  }
}

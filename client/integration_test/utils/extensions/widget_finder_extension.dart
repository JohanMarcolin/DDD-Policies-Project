import 'package:flutter_test/flutter_test.dart';

extension WidgetFinderExtension on Finder {
  Finder findDescendant(Type component) {
    return find.descendant(of: this, matching: find.byType(component));
  }

  Finder findDescendantMatching(Finder matching) {
    return find.descendant(of: this, matching: matching);
  }
}

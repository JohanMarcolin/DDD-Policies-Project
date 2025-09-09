part of 'policy.dart';

sealed class PolicyViolationReason {
  const PolicyViolationReason();
  @override
  String toString() => switch (this) {
        CanNotDeleteSelf() => 'You cannot delete yourself.',
        CanNotDeleteAnalyst() => 'You cannot delete an analyst.',
        CanOnlyDeleteSelf() => 'You can only delete yourself.',
        CanNotModifyAnalyst() => 'You cannot modify an analyst.',
        CanOnlyModifySelf() => 'You can only modify yourself.',
        CanNotViewAnalyst() => 'You cannot view an analyst.',
        CanOnlyViewSelf() => 'You can only view yourself.',
      };
}

class CanNotDeleteSelf extends PolicyViolationReason {}

class CanNotDeleteAnalyst extends PolicyViolationReason {}

class CanOnlyDeleteSelf extends PolicyViolationReason {}

class CanNotModifyAnalyst extends PolicyViolationReason {}

class CanOnlyModifySelf extends PolicyViolationReason {}

class CanNotViewAnalyst extends PolicyViolationReason {}

class CanOnlyViewSelf extends PolicyViolationReason {}

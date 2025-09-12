part of 'policy.dart';

sealed class PolicyPermissionDeniedReason {
  const PolicyPermissionDeniedReason();
  @override
  String toString() => switch (this) {
        CannotDeleteSelf() => 'You cannot delete yourself.',
        CannotDeleteAnalyst() => 'You cannot delete an analyst.',
        CanOnlyDeleteSelf() => 'You can only delete yourself.',
        CannotModifyAnalyst() => 'You cannot modify an analyst.',
        CanOnlyModifySelf() => 'You can only modify yourself.',
        CannotViewAnalyst() => 'You cannot view an analyst.',
        CanOnlyViewSelf() => 'You can only view yourself.',
      };
}

class CannotDeleteSelf extends PolicyPermissionDeniedReason {}

class CannotDeleteAnalyst extends PolicyPermissionDeniedReason {}

class CanOnlyDeleteSelf extends PolicyPermissionDeniedReason {}

class CannotModifyAnalyst extends PolicyPermissionDeniedReason {}

class CanOnlyModifySelf extends PolicyPermissionDeniedReason {}

class CannotViewAnalyst extends PolicyPermissionDeniedReason {}

class CanOnlyViewSelf extends PolicyPermissionDeniedReason {}

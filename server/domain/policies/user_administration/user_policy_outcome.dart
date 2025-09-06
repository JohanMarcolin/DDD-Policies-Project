sealed class UserPolicyOutcome {}

class Granted extends UserPolicyOutcome {}

class Denied extends UserPolicyOutcome {
  Denied({required this.reason});

  final UserPolicyDenialReason reason;
}

sealed class UserPolicyDenialReason {}

class CanNotViewSuperAdmin extends UserPolicyDenialReason {}

class CanOnlyViewSelf extends UserPolicyDenialReason {}

class CanNotDeleteSelf extends UserPolicyDenialReason {}

class CanNotDeleteSuperAdmin extends UserPolicyDenialReason {}

class CanOnlyDeleteSelf extends UserPolicyDenialReason {}

class CanNotModifySuperAdmin extends UserPolicyDenialReason {}

class CanOnlyModifySelf extends UserPolicyDenialReason {}

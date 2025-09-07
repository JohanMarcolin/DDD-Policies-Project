part of 'policy.dart';

sealed class PolicyNonCompliantReason {}

class CanNotDeleteSelf extends PolicyNonCompliantReason {}

class CanNotDeleteAnalyst extends PolicyNonCompliantReason {}

class CanOnlyDeleteSelf extends PolicyNonCompliantReason {}

class CanNotModifyAnalyst extends PolicyNonCompliantReason {}

class CanOnlyModifySelf extends PolicyNonCompliantReason {}

class CanNotViewAnalyst extends PolicyNonCompliantReason {}

class CanOnlyViewSelf extends PolicyNonCompliantReason {}

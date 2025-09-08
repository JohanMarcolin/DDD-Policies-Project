part of 'policy.dart';

sealed class PolicyViolationReason {}

class CanNotDeleteSelf extends PolicyViolationReason {}

class CanNotDeleteAnalyst extends PolicyViolationReason {}

class CanOnlyDeleteSelf extends PolicyViolationReason {}

class CanNotModifyAnalyst extends PolicyViolationReason {}

class CanOnlyModifySelf extends PolicyViolationReason {}

class CanNotViewAnalyst extends PolicyViolationReason {}

class CanOnlyViewSelf extends PolicyViolationReason {}

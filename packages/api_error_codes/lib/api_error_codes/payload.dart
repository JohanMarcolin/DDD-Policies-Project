part of '../api_error_codes.dart';

/// Represents error codes related to payload validation.
sealed class PayloadApiErrorCode extends ApiErrorCode {}

final class PayloadMissingRequestBody extends PayloadApiErrorCode {}

final class PayloadMissingUserId extends PayloadApiErrorCode {}

final class PayloadMissingRole extends PayloadApiErrorCode {}

final class UpdateUserEmailMissingNewEmail extends PayloadApiErrorCode {}

final class UpdateUserEmailInUseBySelf extends PayloadApiErrorCode {}

final class UpdateUserEmailInUseByOther extends PayloadApiErrorCode {}

final class PayloadMissingUserPassword extends PayloadApiErrorCode {}

final class UpdateUserPasswordMissingNewPassword extends PayloadApiErrorCode {}
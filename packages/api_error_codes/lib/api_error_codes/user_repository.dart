part of '../api_error_codes.dart';

/// Represents error codes related to user repository operations.
sealed class UserRepoApiErrorCode extends ApiErrorCode {}

final class UserRepoUserNotFoundById extends UserRepoApiErrorCode {}

final class UserRepoFailedToFetchUsers extends UserRepoApiErrorCode {}

final class UserRepoFailedToFetchUser extends UserRepoApiErrorCode {}

final class UserRepoUserNotFoundByEmail extends UserRepoApiErrorCode {}

final class UserRepoFailedToFetchUserByEmail extends UserRepoApiErrorCode {}

final class UserRepoFailedToUpdateEmail extends UserRepoApiErrorCode {}

final class UserRepoFailedToUpdatePassword extends UserRepoApiErrorCode {}

final class UserRepoFailedToDeleteUser extends UserRepoApiErrorCode {}

final class UserRepoCouldNotVerifyPassword extends UserRepoApiErrorCode {}
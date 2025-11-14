import 'package:global_utils/error_codes.dart';

sealed class RequestException implements Exception {
  const RequestException(this.errorCode);
  final ErrorCode errorCode;

  @override
  String toString() => '${runtimeType.toString()}: ${errorCode.toString()}';
}

class AuthenticatedUserNotFoundException extends RequestException {
  const AuthenticatedUserNotFoundException(super.errorcode);
}

class MissingAuthorizationHeaderException extends RequestException {
  const MissingAuthorizationHeaderException(super.errorcode);
}

class MalformedAuthorizationHeaderException extends RequestException {
  const MalformedAuthorizationHeaderException(super.errorcode);
}

class InvalidAccessTokenException extends RequestException {
  const InvalidAccessTokenException(super.errorcode);
}

class InvalidRefreshTokenException extends RequestException {
  const InvalidRefreshTokenException(super.errorcode);
}

class InvalidUserClaimsException extends RequestException {
  const InvalidUserClaimsException(super.errorcode);
}

class BadRequestException extends RequestException {
  const BadRequestException(super.errorcode);
}

class NotFoundException extends RequestException {
  const NotFoundException(super.errorcode);
}

class ForbiddenException extends RequestException {
  const ForbiddenException(super.errorcode);
}

class ServerErrorException extends RequestException {
  const ServerErrorException(super.errorcode);
}

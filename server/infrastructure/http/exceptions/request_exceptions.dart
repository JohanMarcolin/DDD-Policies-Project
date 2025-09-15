sealed class RequestException implements Exception {
  final String message;
  const RequestException(this.message);

  @override
  String toString() => message;
}

class AuthenticatedUserNotFoundException extends RequestException {
  const AuthenticatedUserNotFoundException(super.message);
}

class MalformedAuthorizationHeaderException extends RequestException {
  const MalformedAuthorizationHeaderException(super.message);
}

class InvalidAccessTokenException extends RequestException {
  const InvalidAccessTokenException(super.message);
}

class InvalidRefreshTokenException extends RequestException {
  const InvalidRefreshTokenException(super.message);
}

class InvalidUserClaimsException extends RequestException {
  const InvalidUserClaimsException(super.message);
}

class BadRequestException extends RequestException {
  const BadRequestException(super.message);
}

class NotFoundException extends RequestException {
  const NotFoundException(super.message);
}

class ForbiddenException extends RequestException {
  const ForbiddenException(super.message);
}

class ServerErrorException extends RequestException {
  const ServerErrorException(super.message);
}

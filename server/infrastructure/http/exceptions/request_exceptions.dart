sealed class RequestException implements Exception {
  final String message;
  const RequestException(this.message);

  @override
  String toString() => message;
}

class AuthenticatedUserNotFoundException extends RequestException {
  const AuthenticatedUserNotFoundException(String message) : super(message);
}

class MalformedAuthorizationHeaderException extends RequestException {
  const MalformedAuthorizationHeaderException(String message) : super(message);
}

class InvalidAccessTokenException extends RequestException {
  const InvalidAccessTokenException(String message) : super(message);
}

class InvalidRefreshTokenException extends RequestException {
  const InvalidRefreshTokenException(String message) : super(message);
}

class InvalidUserClaimsException extends RequestException {
  const InvalidUserClaimsException(String message) : super(message);
}

class BadRequestException extends RequestException {
  const BadRequestException(String message) : super(message);
}

class NotFoundException extends RequestException {
  const NotFoundException(String message) : super(message);
}

class ForbiddenException extends RequestException {
  const ForbiddenException(String message) : super(message);
}

class ServerErrorException extends RequestException {
  const ServerErrorException(String message) : super(message);
}

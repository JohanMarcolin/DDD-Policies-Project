sealed class RequestException implements Exception {
  final String message;
  const RequestException(this.message);

  @override
  String toString() => message;
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

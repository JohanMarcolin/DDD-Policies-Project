part of 'http_api.dart';

sealed class HttpMethod {
  const HttpMethod();
  static const get = Get();
  static const post = Post();
  static const put = Put();
  static const delete = Delete();
}

class Get extends HttpMethod {
  const Get();
}

class Post extends HttpMethod {
  const Post();
}

class Put extends HttpMethod {
  const Put();
}

class Delete extends HttpMethod {
  const Delete();
}

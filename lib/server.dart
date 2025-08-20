import 'package:dart_server/router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'middlewares/jwt.dart';

void main() async {
  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(jwtMiddleware)
      .addHandler(router);

  var server = await shelf_io.serve(handler, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

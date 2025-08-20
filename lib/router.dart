  import 'package:dart_server/handlers/login.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final router = Router()
    ..get('/public', (Request req) => Response.ok('Public endpoint'))
    ..get('/user', (Request req) => Response.ok('User endpoint: Authenticated'))
    ..get(
        '/admin', (Request req) => Response.ok('Admin endpoint: Authenticated'))
    ..get('/data', (Request req) => Response.ok('Data endpoint: Authenticated'))
    ..get('/mock1', (Request req) => Response.ok('Mock endpoint 1'))
    ..get('/mock2', (Request req) => Response.ok('Mock endpoint 2'))
    ..get('/mock3', (Request req) => Response.ok('Mock endpoint 3'))
    ..post('/login', loginHandler);
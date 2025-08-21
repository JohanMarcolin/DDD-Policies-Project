import 'package:uuid/uuid.dart';

class Id {
  Id(this.value);

  final String value;

  factory Id.generate() => Id(Uuid().v4());
}

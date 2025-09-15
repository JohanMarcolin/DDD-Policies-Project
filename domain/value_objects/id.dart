import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class Id extends Equatable {
  Id(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class UserId extends Id {
  UserId(String value) : super(value);

  factory UserId.generate() => UserId(Uuid().v4());
}

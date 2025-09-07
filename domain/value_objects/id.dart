import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Id extends Equatable {
  Id(this.value);

  final String value;

  @override
  List<Object?> get props => [value];

  factory Id.generate() => Id(Uuid().v4());
}

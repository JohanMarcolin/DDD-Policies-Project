import 'package:equatable/equatable.dart';

class Email extends Equatable {
  Email(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

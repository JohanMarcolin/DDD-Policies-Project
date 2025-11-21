import 'package:equatable/equatable.dart';

class Password extends Equatable {
  Password(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

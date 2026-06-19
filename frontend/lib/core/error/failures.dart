import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure(super.message);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

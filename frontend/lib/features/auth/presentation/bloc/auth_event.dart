import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthGuestLoginRequested extends AuthEvent {
  final String? displayName;

  const AuthGuestLoginRequested({this.displayName});

  @override
  List<Object?> get props => [displayName];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String displayName;
  final String password;

  const AuthRegisterRequested({
    required this.username,
    required this.displayName,
    required this.password,
  });

  @override
  List<Object?> get props => [username, displayName, password];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {}

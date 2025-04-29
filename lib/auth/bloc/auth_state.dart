/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information

part of 'auth_bloc.dart';

enum AuthStatus { guest, authenticated }

class AuthState extends Equatable {
  final AuthStatus status;

  const AuthState._({this.status = AuthStatus.guest});

  const AuthState.guest() : this._(status: AuthStatus.guest);

  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);

  @override
  List<Object> get props => [status];
}

/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information

part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String authtoken;

  const LoginSuccess(this.authtoken);

  @override
  bool operator ==(Object other) =>
      other is LoginSuccess && other.authtoken == authtoken;
  @override
  int get hashCode => authtoken.hashCode;
}

class LoginFailure extends LoginState {
  final String? error;

  const LoginFailure(this.error);

  @override
  bool operator ==(Object other) =>
      other is LoginFailure && other.error == error;
  @override
  int get hashCode => error.hashCode;
}

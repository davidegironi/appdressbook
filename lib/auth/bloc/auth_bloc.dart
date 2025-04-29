/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:async';

import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<AuthStatus>? authStatusSubscription;

  AuthBloc({required this.authRepository}) : super(const AuthState.guest()) {
    // register event handlers
    on<AuthStatusChanged>(nAuthStatusChanged);
    on<AuthLogoutRequested>(onAuthLogoutRequested);

    // authentication status subscription
    authStatusSubscription = authRepository.status.listen((status) => add(AuthStatusChanged(status)));
  }

  // handle auth status changes
  void nAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    // check event status
    switch (event.status) {
      case AuthStatus.guest:
        // guest
        emit(const AuthState.guest());
        break;
      case AuthStatus.authenticated:
        // authenticated
        emit(const AuthState.authenticated());
        break;
    }
  }

  // handle logout requests
  Future<void> onAuthLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    // set user to guest, state will be updated via the status
    await authRepository.setGuest();
  }

  @override
  Future<void> close() {
    // suthentication status unsubscription
    authStatusSubscription?.cancel();
    authRepository.dispose();
    return super.close();
  }
}

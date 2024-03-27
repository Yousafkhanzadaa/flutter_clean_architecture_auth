import 'dart:async';
import 'package:bloc_goroute/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bloc_goroute/core/usecase/usecase_interface.dart';
import 'package:bloc_goroute/core/common/entities/user.dart';
import 'package:bloc_goroute/features/auth/domain/usecases/current_user.dart';
import 'package:bloc_goroute/features/auth/domain/usecases/user_sign_up.dart';
import 'package:bloc_goroute/features/auth/domain/usecases/user_signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_authOnSignUp);
    on<AuthSignIn>(_authOnSignIn);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _currentUser(NoParams());

    result.fold(
      (l) => AuthFailure(message: l.message),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  FutureOr<void> _authOnSignUp(
      AuthSignUp event, Emitter<AuthState> emit) async {
    final res = await _userSignUp(UserSignUpParameters(
      email: event.email,
      password: event.password,
      name: event.name,
    ));

    res.fold(
      (faliure) {
        emit(AuthFailure(message: faliure.message));
      },
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  FutureOr<void> _authOnSignIn(
      AuthSignIn event, Emitter<AuthState> emit) async {
    final res = await _userLogin(UserSignInParameters(
      email: event.email,
      password: event.password,
    ));

    res.fold(
      (faliure) {
        emit(AuthFailure(message: faliure.message));
      },
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}

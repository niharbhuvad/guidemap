part of 'auth_cubit.dart';

sealed class AuthState {}

class AuthInitialState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;
  AuthErrorState(this.error);
}

class AuthLoadingState extends AuthState {}

class AuthLoggedInState extends AuthState {
  final AuthUser user;
  AuthLoggedInState(this.user);
}

class AuthLoggedOutState extends AuthState {}

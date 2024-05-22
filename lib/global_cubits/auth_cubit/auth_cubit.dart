import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guidemap/models/auth_user.dart';
import 'package:guidemap/utils/funs.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState()) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      getUserDetails(currentUser);
    }
  }

  void getUserDetails(User user) async {
    final firestore = FirebaseFirestore.instance;
    firestore.collection("users").doc(user.uid).get().then((doc) {
      if (doc.exists) {
        emit(AuthLoggedInState(AuthUser.fromSnapshot(doc)));
      } else {
        emit(AuthErrorState("User details not found!"));
      }
    });
  }

  void signInUser({required String email, required String password}) async {
    emit(AuthLoadingState());
    final auth = FirebaseAuth.instance;
    try {
      final creds = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (creds.user != null) {
        getUserDetails(creds.user!);
      } else {
        emit(AuthLoggedOutState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void registerUser({
    required String email,
    required String username,
    required String name,
    required String password,
  }) async {
    emit(AuthLoadingState());
    final firestore = FirebaseFirestore.instance;
    final doc = firestore.collection("users").where(Filter.or(
        Filter("email", isEqualTo: email),
        Filter("username", isEqualTo: username)));
    final data = await doc.where("email", isEqualTo: email).count().get();
    if (data.count != null) {
      if (data.count! > 0) {
        emit(AuthErrorState("Email already in use!"));
        return;
      } else {
        final data2 =
            await doc.where("username", isEqualTo: username).count().get();
        if (data2.count != null) {
          if (data2.count! > 0) {
            emit(AuthErrorState("Username already taken!"));
            return;
          }
        } else {
          emit(AuthErrorState("Something went wrong!"));
          return;
        }
      }
      final auth = FirebaseAuth.instance;
      final creds = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (creds.user != null) {
        await firestore.collection("users").doc(creds.user!.uid).set({
          "email": email,
          "username": username,
          "name": name,
          "mobile": null,
        });
        final data3 =
            await firestore.collection("users").doc(creds.user!.uid).get();
        if (data3.exists) {
          signInUser(email: email, password: password);
          return;
        }
      }
    }
    emit(AuthErrorState("Registration Failed!"));
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    emit(AuthLoggedOutState());
    // ignore: use_build_context_synchronously
    context.go('/auth/login');
  }

  Future<void> sendForgotPasswordLink({
    required BuildContext context,
    required String email,
  }) async {
    emit(AuthLoadingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Password reset email send successfully.');
      emit(AuthInitialState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}

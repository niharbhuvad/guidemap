import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guidemap/screens/add_region/add_region_screen.dart';
import 'package:guidemap/screens/auth/auth_screen.dart';
import 'package:guidemap/screens/edit_region/edit_region_screen.dart';
import 'package:guidemap/screens/error_page.dart';
import 'package:guidemap/screens/home/home_screen.dart';
import 'package:guidemap/screens/view_region/view_region_screen.dart';
import 'package:guidemap/utils/funs.dart';

class XRouter {
  const XRouter._();
  static final router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      if (isAuthenticated(context) && state.uri.pathSegments.first == 'auth') {
        return '/home';
      }
      if (!isAuthenticated(context)) {
        return '/auth/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/:page',
        builder: (context, state) {
          final page = state.pathParameters['page'] ?? '';
          final pageList = ['login', 'register', 'forgot-password'];
          if (pageList.contains(page)) {
            return const AuthScreen();
          } else {
            return const ErrorPage();
          }
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/add_region',
        builder: (context, state) {
          return const AddRegionScreen();
        },
      ),
      GoRoute(
        path: '/edit_region/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isNotEmpty) {
            return EditRegionScreen(id);
          } else {
            return const ErrorPage();
          }
        },
      ),
      GoRoute(
        path: '/view_region/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isNotEmpty) {
            return ViewRegionScreen(id);
          } else {
            return const ErrorPage();
          }
        },
      ),
    ],
  );

  static RouterDelegate get routerDel => router.routerDelegate;

  static Uri get currentUri => router.routeInformationProvider.value.uri;
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guidemap/firebase_options.dart';
import 'package:guidemap/global_cubits/auth_cubit/auth_cubit.dart';
import 'package:guidemap/utils/x_consts.dart';
import 'package:guidemap/utils/x_router.dart';
import 'package:guidemap/utils/x_themes.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: XConsts.appName,
        theme: XThemes.appTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: XRouter.router,
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guidemap/global_cubits/auth_cubit/auth_cubit.dart';
import 'package:guidemap/screens/auth/comps/auth_password_field.dart';
import 'package:guidemap/utils/extensions.dart';
import 'package:guidemap/utils/x_consts.dart';
import 'package:guidemap/utils/x_router.dart';
import 'package:guidemap/utils/x_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String pageName;
  // Form Key & Controllers
  late GlobalKey<FormState> _formKey; // = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    pageName = XRouter.currentUri.pathSegments.last;
    _formKey = GlobalKey<FormState>();
    final colorScheme = Theme.of(context).colorScheme;
    final List pageData = (pageName == 'register')
        ? [
            "Create your account",
            "Already have an account? ",
            "Login",
            "/auth/login",
          ]
        : (pageName == 'forgot-password')
            ? [
                "Enter your email to get password reset link.",
                "Remembered password? ",
                "Go to Login",
                "/auth/login",
              ]
            : [
                "Enter your credentials to login",
                "Dont have an account? ",
                "Register",
                "/auth/register",
              ];
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedInState) {
          context.go('/home');
        }
      },
      child: Title(
        color: colorScheme.primary,
        title: XRouter.currentUri.pathSegments.last.toTitleCase(),
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(width: 0.3, color: colorScheme.secondary),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      XConsts.appName.toUpperCase(),
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      pageData[0],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.primary.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // const SizedBox(height: 40),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthErrorState) {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(top: 40, bottom: 20),
                            decoration: BoxDecoration(
                                color: colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(
                              state.error,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox(height: 40);
                      },
                    ),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: (pageName == 'forgot-password')
                          ? getForgotPasswordForm(context, colorScheme)
                          : (pageName == 'register')
                              ? getRegisterForm(context, colorScheme)
                              : getLoginForm(context, colorScheme),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: Text("OR"),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: pageData[1]),
                          TextSpan(
                            text: pageData[2],
                            style: const TextStyle(
                              // color: AppThemes.darkGreyColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push(pageData[3]),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginForm(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        getEmailTextField(colorScheme),
        const SizedBox(height: 20),
        AuthPasswordField(
          controller: _passwordController,
          onSubmit: submitForm,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 20),
          child: InkWell(
            onTap: () => context.push('/auth/forgot-password'),
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        getSubmitButton(context, 'Login', false, colorScheme),
      ],
    );
  }

  Widget getRegisterForm(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        getEmailTextField(colorScheme),
        const SizedBox(height: 20),
        Material(
          color: colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(5),
          child: TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration:
                getTextFieldDecoration("Username", Icons.account_circle),
          ),
        ),
        const SizedBox(height: 20),
        Material(
          color: colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(5),
          child: TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: getTextFieldDecoration("Your Name", Icons.abc),
          ),
        ),
        const SizedBox(height: 20),
        AuthPasswordField(
          controller: _passwordController,
          onSubmit: submitForm,
        ),
        const SizedBox(height: 40),
        getSubmitButton(context, 'Register', true, colorScheme),
      ],
    );
  }

  Widget getForgotPasswordForm(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        getEmailTextField(colorScheme),
        const SizedBox(height: 20),
        getSubmitButton(context, 'Submit', false, colorScheme),
      ],
    );
  }

  Widget getSubmitButton(
      context, String label, bool isRegister, ColorScheme colorScheme) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return XWidgets.textBtn(
          text: label,
          loading: state is AuthLoadingState,
          onPressed: () => submitForm(context),
        );
      },
    );
  }

  Material getEmailTextField(ColorScheme colorScheme) {
    return Material(
      color: colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(5),
      child: TextFormField(
        controller: _emailController,
        autofillHints: const [AutofillHints.email],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textInputAction: (pageName == 'forgot-password')
            ? TextInputAction.done
            : TextInputAction.next,
        decoration: getTextFieldDecoration("Email", Icons.mail),
      ),
    );
  }

  InputDecoration getTextFieldDecoration(String hint, IconData iconData) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: hint,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(iconData, size: 20),
      ),
      contentPadding: const EdgeInsets.all(15),
    );
  }

  void submitForm(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is! AuthLoadingState) {
      if (_formKey.currentState?.validate() ?? false) {
        final auth = FirebaseAuth.instance;
        if (auth.currentUser != null) {
          authCubit.getUserDetails(auth.currentUser!);
        } else if (pageName == 'forgot-password') {
          authCubit.sendForgotPasswordLink(
            context: context,
            email: _emailController.text.toLowerCase(),
          );
        } else if (pageName == 'register') {
          authCubit.registerUser(
            email: _emailController.text.toLowerCase(),
            username: _usernameController.text.toLowerCase(),
            name: _nameController.text,
            password: _passwordController.text,
          );
        } else {
          authCubit.signInUser(
            email: _emailController.text.toLowerCase(),
            password: _passwordController.text,
          );
        }
      }
    }
  }
}

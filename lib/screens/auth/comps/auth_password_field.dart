import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(BuildContext) onSubmit;
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool passwordHide = true;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(5),
      child: TextFormField(
        controller: widget.controller,
        obscureText: passwordHide,
        onEditingComplete: () {
          widget.onSubmit(context);
        },
        keyboardType: TextInputType.visiblePassword,
        autofillHints: const [AutofillHints.password],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Password",
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.lock),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              tooltip: (passwordHide ? 'Show' : 'Hide'),
              icon:
                  Icon(passwordHide ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => passwordHide = !passwordHide),
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}

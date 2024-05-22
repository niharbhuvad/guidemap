import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMsg;
  const ErrorPage({super.key, this.errorMsg});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Text(
          errorMsg ?? '404 Page not found!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

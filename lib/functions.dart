import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String txt) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

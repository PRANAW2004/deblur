import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message,
    {Color color = Colors.black}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

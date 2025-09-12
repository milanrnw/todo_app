import 'package:flutter/material.dart';

class Appconstant {
  Appconstant._();
  static showSnackBar(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }
}

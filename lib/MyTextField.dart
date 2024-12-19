import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Function(dynamic) onChanged;

  const MyTextField({
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: hintText,
      ),
      onChanged: (value) {
        onChanged(value);
      },
    );
  }
}

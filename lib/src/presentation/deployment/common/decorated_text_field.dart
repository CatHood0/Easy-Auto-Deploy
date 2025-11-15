import 'package:flutter/material.dart';

class DecoratedTextField extends StatelessWidget {
  const DecoratedTextField({
    super.key,
    required this.controller,
    this.onFieldSubmitted,
    this.validator,
    this.icon,
    this.labelText,
    this.obscureText = false,
    this.maxLines,
    this.input,
    this.onChanged,
  });

  final TextEditingController controller;
  final Icon? icon;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? labelText;
  final bool obscureText;
  final int? maxLines;
  final TextInputType? input;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      keyboardType: input ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 12,
        ),
        border: OutlineInputBorder(),
        prefixIcon: icon,
      ),
    );
  }
}

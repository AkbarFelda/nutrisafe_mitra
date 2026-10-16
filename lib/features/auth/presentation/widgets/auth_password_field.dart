import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText,
    this.allowReveal = true,
    this.autofillHints,
  });
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String? hintText;
  final bool allowReveal;
  final Iterable<String>? autofillHints;
  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    validator: widget.validator,
    obscureText: _obscure,
    autocorrect: false,
    enableSuggestions: false,
    autofillHints: widget.autofillHints,
    decoration: InputDecoration(
      hintText: widget.hintText,
      errorMaxLines: 3,
      suffixIcon: widget.allowReveal
          ? IconButton(
              tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            )
          : null,
    ),
  );
}

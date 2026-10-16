import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SppgFormField extends StatelessWidget {
  const SppgFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofillHints,
    this.optional = false,
  });
  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final bool optional;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      autofillHints: autofillHints,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: optional ? '$label (opsional)' : label,
        errorMaxLines: 3,
      ),
    ),
  );
}

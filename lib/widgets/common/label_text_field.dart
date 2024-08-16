import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabelTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  int? maxLines;
  bool? readOnlyVal;
  TextStyle? style;
  Widget? suffixIcon;
  List<TextInputFormatter>? inputFormatters;
  ValueChanged<String>? onChanged;
  InputDecoration? decoration;
  final TextInputAction? textInputAction;
  void Function()? onSubmit;
  final TextInputType? keyboardType;
  final String? suffixText;
  final TextAlign? textAlign;
  TextStyle? labelTextStyle;
  OutlineInputBorder? focusedBorder;
  OutlineInputBorder? enabledBorder;

  LabelTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines,
    this.readOnlyVal,
    this.style,
    this.inputFormatters,
    this.suffixIcon,
    this.onChanged,
    this.decoration,
    this.textInputAction,
    this.onSubmit,
    this.keyboardType,
    this.suffixText,
    this.textAlign,
    this.labelTextStyle,
    this.focusedBorder,
    this.enabledBorder,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (value) {
        onSubmit;
      },
      textInputAction: textInputAction,
      onChanged: onChanged,
      readOnly: readOnlyVal ?? false,
      maxLines: maxLines,
      controller: controller,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        labelText: label,
        suffixText: suffixText,
        labelStyle: labelTextStyle,
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
      ),
      style: style,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}

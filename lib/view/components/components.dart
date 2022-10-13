import 'package:clinico/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget defaultElevatedButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required String buttonText,
  TextStyle? buttonTextStyle,
  double shapeBorderRadius = 10,
  Color? primary,
}) =>
    ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: primary ?? AppColors.appPrimaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(shapeBorderRadius))),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: buttonTextStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white, fontSize: 20),
      ),
    );

Widget defaultTextFormField({
  required BuildContext context,
  required TextEditingController controller,
  bool enabled = true,
  TextStyle? style,
  String? labelText,
  String? hintText,
  TextStyle? hintStyle,
  TextStyle? labelStyle,
  bool filled = true,
  Color fillColor = Colors.white,
  double borderWidth = 1,
  double borderRadios = 10,
  Color borderColor = Colors.white,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onFieldSubmitted,
  FormFieldValidator<String>? validator,
  TextInputType keyboardType = TextInputType.text,
}) =>
    TextFormField(
      style: style ?? const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(8),
        enabled: enabled,
        filled: filled,
        fillColor: fillColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadios),
            borderSide: BorderSide(width: borderWidth, color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadios),
            borderSide: BorderSide(width: borderWidth, color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadios),
            borderSide: BorderSide(width: borderWidth, color: borderColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadios),
            borderSide: BorderSide(width: borderWidth, color: borderColor)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadios),
            borderSide: BorderSide(width: borderWidth, color: borderColor)),
        labelText: labelText,
        labelStyle: labelStyle ?? const TextStyle(fontSize: 18),
        hintText: hintText,
        hintStyle: hintStyle ?? const TextStyle(fontSize: 18),
      ),
      controller: controller,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
    );

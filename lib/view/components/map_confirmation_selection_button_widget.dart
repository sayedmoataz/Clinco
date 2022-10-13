import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

Widget mapConfirmationSelectionButtonWidget() {
  return Container(
    alignment: Alignment.center,
    height: 50.0,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80.0),
        color: AppColors.primaryColor),
    padding: const EdgeInsets.all(0),
    child: const Text(
      "إختيـــار",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
    ),
  );
}

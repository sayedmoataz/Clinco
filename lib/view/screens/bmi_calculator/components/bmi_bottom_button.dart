import 'package:clinico/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../constants/bmi_constants.dart';

class BmiBottomButton extends StatelessWidget {
  const BmiBottomButton(
      {Key? key, required this.onTap, required this.buttonTitle})
      : super(key: key);

  final Function()? onTap;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.primaryColor,
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.all(10.0),
        width: double.infinity,
        height: kBottomContainerHeight,
        child: Center(
          child: Text(
            buttonTitle,
            style: kLargeButtonTextStyle,
          ),
        ),
      ),
    );
  }
}

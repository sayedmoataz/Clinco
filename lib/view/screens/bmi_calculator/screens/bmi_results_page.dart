import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/bmi_constants.dart';
import '../../../../model/bmi_result.dart';
import '../components/bmi_bottom_button.dart';
import '../components/bmi_reusable_card.dart';

class BmiResultsPage extends StatelessWidget {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;

  BmiResultsPage({Key? key, required this.bmiResult}) : super(key: key);
  final BmiResult bmiResult;

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Expanded(
                child: Center(
                  child: Text(
                    'نتيجتك',
                    style: kTitleTextStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: BmiReusableCard(
                  colour: kActiveCardColour,
                  cardChild: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        bmiResult.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            bmiResult.bmiValue,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 65.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          Image.asset(
                            bmiResult.imagePath,
                            width: 30,
                            height: 60,
                          )
                        ],
                      ),
                      Text(
                        bmiResult.description.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              BmiBottomButton(
                buttonTitle: 'إعادة الحساب',
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ));
  }
}

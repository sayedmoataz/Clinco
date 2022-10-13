import 'dart:ui' as ui;

import 'package:clinico/view/screens/bmi_calculator/screens/bmi_results_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/bmi_constants.dart';
import '../../../../helper/bmi_calculator.dart';
import '../components/bmi_bottom_button.dart';
import '../components/bmi_icon_content.dart';
import '../components/bmi_reusable_card.dart';

enum Gender {
  male,
  female,
}

class BmiInputPage extends StatefulWidget {
  const BmiInputPage({Key? key}) : super(key: key);

  @override
  _BmiInputPageState createState() => _BmiInputPageState();
}

class _BmiInputPageState extends State<BmiInputPage> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Gender selectedGender = Gender.male;
  int height = 180, weight = 60, age = 20;

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('مؤشر كتلة الجسم BMI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    child: BmiReusableCard(
                      onPress: () {
                        setState(() {
                          selectedGender = Gender.male;
                        });
                      },
                      colour: selectedGender == Gender.male
                          ? kActiveCardColour
                          : kInactiveCardColour,
                      cardChild: BmiIconContent(
                        icon: FontAwesomeIcons.mars,
                        label: 'ذكر',
                      ),
                    ),
                  ),
                  Expanded(
                    child: BmiReusableCard(
                      onPress: () {
                        setState(() {
                          selectedGender = Gender.female;
                        });
                      },
                      colour: selectedGender == Gender.female
                          ? kActiveCardColour
                          : kInactiveCardColour,
                      cardChild: BmiIconContent(
                        icon: FontAwesomeIcons.venus,
                        label: 'أنثى',
                      ),
                    ),
                  ),
                ],
              )),
              Expanded(
                child: BmiReusableCard(
                  colour: kActiveCardColour,
                  cardChild: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'الطول',
                        style: kLabelTextStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            height.toString(),
                            style: kNumberTextStyle,
                          ),
                          const Text(
                            'سم',
                            style: kLabelTextStyle,
                          )
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          inactiveTrackColor: const Color(0xFF8D8E98),
                          activeTrackColor: Colors.white,
                          thumbColor: Colors.white,
                          overlayColor: const Color(0xB5FFFFFF),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 15.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 30.0),
                        ),
                        child: Slider(
                          value: height.toDouble(),
                          min: 120.0,
                          max: 220.0,
                          onChanged: (double newValue) {
                            setState(() {
                              height = newValue.round();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: BmiReusableCard(
                        colour: kActiveCardColour,
                        cardChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'الوزن',
                              style: kLabelTextStyle,
                            ),
                            Text(
                              weight.toString(),
                              style: kNumberTextStyle,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ClipOval(
                                  child: Material(
                                    color: AppColors.secondaryColor2,
                                    child: InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(() {
                                          if (weight > 0) {
                                            weight--;
                                          }
                                        });
                                      },
                                      child: const SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(FontAwesomeIcons.minus,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                ClipOval(
                                  child: Material(
                                    color: AppColors.secondaryColor2,
                                    child: InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(
                                          () {
                                            weight++;
                                          },
                                        );
                                      },
                                      child: const SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(
                                            FontAwesomeIcons.plus,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: BmiReusableCard(
                        colour: kActiveCardColour,
                        cardChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'العمر',
                              style: kLabelTextStyle,
                            ),
                            Text(
                              age.toString(),
                              style: kNumberTextStyle,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ClipOval(
                                  child: Material(
                                    color: AppColors.secondaryColor2,
                                    child: InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(
                                          () {
                                            if (age > 0) age--;
                                          },
                                        );
                                      },
                                      child: const SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(FontAwesomeIcons.minus,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                ClipOval(
                                  child: Material(
                                    color: AppColors.secondaryColor2,
                                    child: InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(
                                          () {
                                            age++;
                                          },
                                        );
                                      },
                                      child: const SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(FontAwesomeIcons.plus,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BmiBottomButton(
                buttonTitle: 'احســــب',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BmiResultsPage(
                            bmiResult:
                                BmiCalculator().getBmiResult(height, weight))),
                  );
                },
              ),
            ],
          ),
        ));
  }
}

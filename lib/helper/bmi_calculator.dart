import 'dart:math';

import 'package:flutter/material.dart';

import '../model/bmi_result.dart';

class BmiCalculator {
  static final BmiCalculator _bmiCalculator = BmiCalculator._internal();

  factory BmiCalculator() => _bmiCalculator;

  BmiCalculator._internal();

  List<String> titles = [
    'وزن أقل من الطبيعي',
    'وزن طبيعي',
    'وزن زائد',
    'سمنة بسيطة(سمنة من الدرجة الأولى)',
    'سمنة متوسطة (سمنة من الدرجة الثانية)',
    'سمنة مفرطة'
  ];

  List<String> descriptions = [
    'محتاج تاكل أكتر لكن بشكل صحي و سليم مع ممارسة الرياضة بشكل مستمر لزيادة الكتلة العضلية',
    'وزنك ممتاز، حافظ عليه',
    'تحتاج لعمل نظام غذائي (رجيم) لنزول الوزن لكن بشكل صحي و سليم وبشكل تدريجي مع ممارسة الرياضة',
    'تحتاج لعمل نظام غذائي (رجيم) لنزول الوزن لكن بشكل سليم و بشكل تدريجي بجانب ممارسة الرياضة',
    'تحتاج لعمل نظام غذائي (رجيم) لنزول الوزن لكن بشكل سليم و بشكل تدريجي بجانب ممارسة الرياضة',
    'في ذلك خطورة على القلب والكبد و المفاصل، وتحتاج لعمل نظام غذائي (رجيم) لنزول الوزن لكن بشكل صحي وسليم وبشكل تدريجي'
  ];

  BmiResult getBmiResult(int height, int weight) {
    double bmi = weight / pow(height / 100, 2);

    if (bmi < 18.5) {
      return BmiResult(bmi.toStringAsFixed(1), titles[0], descriptions[0],
          'assets/images/bmi_0.jpeg', Colors.cyanAccent);
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return BmiResult(bmi.toStringAsFixed(1), titles[1], descriptions[1],
          'assets/images/bmi_1.jpeg', Colors.lightGreen);
    } else if (bmi >= 25 && bmi <= 29.9) {
      return BmiResult(bmi.toStringAsFixed(1), titles[2], descriptions[2],
          'assets/images/bmi_2.jpeg', Colors.yellow);
    } else if (bmi >= 30 && bmi <= 34.9) {
      return BmiResult(bmi.toStringAsFixed(1), titles[3], descriptions[3],
          'assets/images/bmi_3.jpeg', Colors.orange);
    } else if (bmi >= 35 && bmi <= 39.9) {
      return BmiResult(bmi.toStringAsFixed(1), titles[4], descriptions[4],
          'assets/images/bmi_4.jpeg', Colors.deepOrange);
    } else {
      return BmiResult(bmi.toStringAsFixed(1), titles[5], descriptions[5],
          'assets/images/bmi_5.jpeg', Colors.red);
    }
  }
}

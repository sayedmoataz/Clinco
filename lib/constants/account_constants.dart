import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/user_data.dart';
import '../model/week_day.dart';

class AccountConstants {
  static RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
  static const List<String> arabicCountriesNames = ['مصر', 'السعودية'];
  static const List<String> arabicAccountTypes = [
    'مريض',
    'مدير التطبيق',
    'طبيب',
    'شركة',
    'مركز اشعة',
    'معمل تحاليل'
  ];
  static const List<String> accountTypes = [
    'مريض',
    'طبيب',
    'شركة',
    'مدير التطبيق',
    'مركز اشعة',
    'معمل تحاليل'
  ];
  static const List<String> genderTypes = ['ذكر', 'أنثى'];
  static const List<String> accountStatusTitleList = [
    'قيد المراجعة',
    'مقبول',
    'مرفوض'
  ];
  static List<Icon> accountStatusIconList = [
    Icon(
      FontAwesomeIcons.spinner,
      color: accountStatusColor[0],
    ),
    Icon(FontAwesomeIcons.circleCheck, color: accountStatusColor[1]),
    Icon(FontAwesomeIcons.circleXmark, color: accountStatusColor[2])
  ];
  static const List<Color> accountStatusColor = [
    Color(0xFFFFCA22),
    Color(0xFF34BF00),
    Color(0xFFFA1225)
  ];
  static const List<String> doctorLevels = [
    'طالب',
    'ممارس',
    'أخصائي',
    'استشاري'
  ];
  static const List<String> clinicPaymentWays = [
    'أون لاين/نقدي',
    'أون لاين',
    'نقدي'
  ];
  static const List<String> clinicRevealWays = [
    'مكالمة دكتور/حجز عيادة',
    'مكالمة دكتور',
    'حجز عيادة'
  ];
  static const List<String> appointmentStatus = [
    'لم يتم بعد',
    'تم الكشف',
    'أُلغيت من قِبل الطبيب',
    'أُلغيت من قِبل المريض',
    'تم انقضاء الوقت دون الكشف'
  ];
  static const List<int> phoneNumberDigitsCount = [11, 9];

  static int getPhoneNumberDigitCountByCountryName(String selectedCountry) =>
      selectedCountry == Countries.Egypt.name
          ? phoneNumberDigitsCount.first
          : phoneNumberDigitsCount.last;

  static String getPriceCurrencyByCountry(String selectedCountry) =>
      selectedCountry == Countries.Egypt.name ? 'ج.م' : 'ر.س';

  static String getPriceWithOffer(int price) =>
      (price - ((5 / 100) * price)).toString().replaceAll(regex, '');

  static const List<String> weekDaysInEnglishLanguageStartingByMonday = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  static const List<String> weekDaysInArabicLanguageStartingByMonday = [
    'الأثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعه',
    'السبت',
    'الأحد'
  ];

  static const List<String> weekDaysInEnglishLanguage = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  static const List<String> weekDaysInArabicLanguage = [
    'السبت',
    'الأحد',
    'الأثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعه'
  ];

  static List<WeekDay> weekDays = [
    WeekDay(weekDaysInArabicLanguage[0], weekDaysInEnglishLanguage[0]),
    WeekDay(weekDaysInArabicLanguage[1], weekDaysInEnglishLanguage[1]),
    WeekDay(weekDaysInArabicLanguage[2], weekDaysInEnglishLanguage[2]),
    WeekDay(weekDaysInArabicLanguage[3], weekDaysInEnglishLanguage[3]),
    WeekDay(weekDaysInArabicLanguage[4], weekDaysInEnglishLanguage[4]),
    WeekDay(weekDaysInArabicLanguage[5], weekDaysInEnglishLanguage[5]),
    WeekDay(weekDaysInArabicLanguage[6], weekDaysInEnglishLanguage[6])
  ];

  static const defaultInitialMapLocation = LatLng(30.044353, 31.235708);
}

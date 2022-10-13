import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeHelper {
  static final TimeHelper _singleton = TimeHelper._internal();

  factory TimeHelper() => _singleton;

  TimeHelper._internal();

  Iterable<DateTime> getTimes(DateTime selectedDateTime, Timestamp startTime,
      Timestamp endTime, int interval) sync* {
    final step = Duration(minutes: interval);
    DateTime startDate = startTime.toDate();
    DateTime endDate = endTime.toDate();
    var hour = startDate.hour;
    var minute = startDate.minute;

    do {
      yield DateTime(selectedDateTime.year, selectedDateTime.month,
          selectedDateTime.day, hour, minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endDate.hour ||
        (hour == endDate.hour && minute <= endDate.minute));
  }

  int differenceBetweenTwoTimeOfDays(
      TimeOfDay firstTime, TimeOfDay secondTime) {
    int firstTimeInMinutes = firstTime.hour * 60 + firstTime.minute;
    int secondTimeInMinutes = secondTime.hour * 60 + secondTime.minute;

    int diffInMinutes = secondTimeInMinutes - firstTimeInMinutes;
    return diffInMinutes;
  }
}

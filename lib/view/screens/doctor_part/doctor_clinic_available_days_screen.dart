import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/account_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../model/clinic.dart';
import '../../../model/week_day.dart';
import 'doctor_clinic_available_day_time_ranges_screen.dart';

class DoctorClinicAvailableDaysScreen extends StatefulWidget {
  String? clinicDocumentPath, clinicId;
  Clinic? clinic;

  DoctorClinicAvailableDaysScreen(
      {Key? key,
      required this.clinicDocumentPath,
      required this.clinic,
      required this.clinicId})
      : super(key: key);

  @override
  _DoctorClinicAvailableDaysScreenState createState() =>
      _DoctorClinicAvailableDaysScreenState();
}

class _DoctorClinicAvailableDaysScreenState
    extends State<DoctorClinicAvailableDaysScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  final List<WeekDay> _weekDays = AccountConstants.weekDays;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('مواعيد عمل ${widget.clinic?.name ?? ''}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: getDayList(),
        ));
  }

  getDayList() {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              itemCount: _weekDays.length,
              itemBuilder: (BuildContext context, int i) {
                return _buildDayWidget(_weekDays[i]);
              }),
        ),
      ],
    );
  }

  _buildDayWidget(WeekDay weekDay) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoctorClinicAvailableDayTimeRangesScreen(
                  clinicDocumentPath: widget.clinicDocumentPath,
                  clinic: widget.clinic,
                  weekDay: weekDay,
                  clinicId: widget.clinicId))),
          child: ListTile(
            title: Text(
              weekDay.dayNameArabic,
              style: TextStyle(fontSize: 16, color: primaryLightColor),
            ),
            leading: SizedBox(
              height: double.infinity,
              child: Icon(
                FontAwesomeIcons.solidCircleDot,
                color: primaryLightColor,
              ),
            ),
            trailing: SizedBox(
              height: double.infinity,
              child: Icon(
                FontAwesomeIcons.angleLeft,
                color: primaryLightColor,
                size: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/account_constants.dart';
import '../../../constants/app_colors.dart';

class DoctorLevelSelectionScreen extends StatefulWidget {
  const DoctorLevelSelectionScreen({Key? key}) : super(key: key);

  @override
  _DoctorLevelSelectionScreenState createState() =>
      _DoctorLevelSelectionScreenState();
}

class _DoctorLevelSelectionScreenState
    extends State<DoctorLevelSelectionScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<String> doctorLevels = AccountConstants.doctorLevels;

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('مستويات الطبيب',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: getDoctorLevelList(),
        ));
  }

  getDoctorLevelList() {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              itemCount: doctorLevels.length,
              itemBuilder: (context, index) =>
                  _buildDoctorLevelWidget(doctorLevels[index])),
        ),
      ],
    );
  }

  _buildDoctorLevelWidget(String doctorLevel) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => Navigator.pop(context, doctorLevel),
          child: ListTile(
            title: Text(
              doctorLevel,
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

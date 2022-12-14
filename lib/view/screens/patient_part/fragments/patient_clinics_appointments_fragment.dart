import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../helper/shared_preferences.dart';
import '../../../../model/booking_request.dart';
import '../../../../model/user_data.dart';
import '../../view_appointment_details_screen.dart';

class PatientClinicsAppointmentsFragment extends StatefulWidget {
  final String screenTitle;

  const PatientClinicsAppointmentsFragment(
      {Key? key, required this.screenTitle})
      : super(key: key);

  @override
  _PatientClinicsAppointmentsFragmentState createState() =>
      _PatientClinicsAppointmentsFragmentState();
}

class _PatientClinicsAppointmentsFragmentState
    extends State<PatientClinicsAppointmentsFragment> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  final DateFormat timeFormat =
          DateFormat('EEEE  yyyy/MM/dd - hh:mm a', 'ar_KSA'),
      dayFormatEnglish = DateFormat('EEE');
  late final AppData _appData;
  String? _userId;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Query<Map<String, dynamic>>? _fetchingQuery;
  final List<BookingRequest> _bookingRequests = <BookingRequest>[];

  @override
  void initState() {
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _userId = _appData.getUserId(pref!)!;
      setState(() {
        _fetchingQuery = _firebaseFirestore
            .collection(FirestoreCollections.ClinicBookingRequests.name)
            .orderBy('date', descending: true)
            .where('patientUserId', isEqualTo: _userId);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.screenTitle,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
              // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
            ),
            body: _fetchingQuery != null ? itemList() : null));
  }

  Widget itemList() => StreamBuilder(
      stream: _fetchingQuery?.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
                child: Text(
              '???????????? ???? ???????? ????????????!',
              style: TextStyle(color: primaryLightColor),
            ));
          }
          Map map = (docs).asMap();
          _bookingRequests.clear();
          map.forEach((dynamic, json) =>
              _bookingRequests.add(BookingRequest.fromJson(json)));
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, i) {
                return _buildPatientAppointmentWidget(_bookingRequests[i],
                    docs[i].reference.path, docs[i].reference.id);
              });
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            '???????????? ?????? ?????? ????!',
            style: TextStyle(color: Colors.red),
          ));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(
            child: Text(
          '???????????? ?????? ?????? ????!',
          style: TextStyle(color: Colors.red),
        ));
      });

  _buildPatientAppointmentWidget(BookingRequest bookingRequest,
      String bookingRequestDocumentPath, String bookingRequestDocumentId) {
    return Container(
      // color:primaryLightColor,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: AppColors.appPrimaryColor
          border: Border.all(color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ViewAppointmentDetailsScreen(
                  bookingRequest: bookingRequest,
                  bookingRequestDocumentPath: bookingRequestDocumentPath,
                  bookingRequestDocumentId: bookingRequestDocumentId))),
          child: ListTile(
            leading: SizedBox(
              height: double.infinity,
              child: _getAppointmentStatusIcon(bookingRequest.isBookingExpired
                  ? 4
                  : bookingRequest.appointmentStatus),
            ),
            title: Text(
              timeFormat.format(bookingRequest.date!.toDate()),
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            trailing: const SizedBox(
              height: double.infinity,
              child: Icon(FontAwesomeIcons.angleLeft,
                  color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Icon? _getAppointmentStatusIcon(int appointmentStatus) {
    switch (appointmentStatus) {
      case 0:
        return const Icon(FontAwesomeIcons.hourglass,
            color: AppColors.secondaryColor2, size: 25);
        break;
      case 1:
        return const Icon(FontAwesomeIcons.circleCheck,
            color: AppColors.secondaryColor3, size: 25);
        break;
      case 4:
        return const Icon(FontAwesomeIcons.circleExclamation,
            color: AppColors.secondaryColor5, size: 25);
        break;
      default:
        return const Icon(FontAwesomeIcons.circleXmark,
            color: AppColors.secondaryColor4, size: 25);
        break;
    }
  }
}

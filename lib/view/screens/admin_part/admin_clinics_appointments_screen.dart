import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_colors.dart';
import '../../../model/booking_request.dart';
import '../../../model/user_data.dart';
import '../view_appointment_details_screen.dart';

class AdminClinicsAppointmentsScreen extends StatefulWidget {
  const AdminClinicsAppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AdminClinicsAppointmentsScreenState createState() =>
      _AdminClinicsAppointmentsScreenState();
}

class _AdminClinicsAppointmentsScreenState
    extends State<AdminClinicsAppointmentsScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  final DateFormat timeFormat =
          DateFormat('EEEE  yyyy/MM/dd - hh:mm a', 'ar_KSA'),
      dayFormatEnglish = DateFormat('EEE');
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Query<Map<String, dynamic>>? _fetchingQuery;
  final List<BookingRequest> _bookingRequests = <BookingRequest>[];

  @override
  void initState() {
    _fetchingQuery = _firebaseFirestore
        .collection(FirestoreCollections.ClinicBookingRequests.name)
        .orderBy('date', descending: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('حجوزات العيادات',
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
              'عفواً، لا يوجد بيانات!',
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
                return _buildAdminAppointmentWidget(_bookingRequests[i],
                    docs[i].reference.path, docs[i].reference.id);
              });
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            'عفواً، حدث خطأ ما!',
            style: TextStyle(color: Colors.red),
          ));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(
            child: Text(
          'عفواً، حدث خطأ ما!',
          style: TextStyle(color: Colors.red),
        ));
      });

  _buildAdminAppointmentWidget(BookingRequest bookingRequest,
      String bookingRequestDocumentPath, String bookingRequestDocumentId) {
    return Card(
      color: primaryLightColor,
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
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            trailing: const SizedBox(
              height: double.infinity,
              child: Icon(FontAwesomeIcons.angleLeft,
                  color: Colors.white, size: 18),
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

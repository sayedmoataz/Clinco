import 'package:clinico/model/admin.dart';
import 'package:clinico/model/company.dart';
import 'package:clinico/model/patient.dart';
import 'package:clinico/model/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../helper/shared_preferences.dart';
import '../../../model/doctor.dart';
import '../../../model/speciality.dart';
import '../../components/user_profile_widget.dart';
import '../admin_part/edit_admin_profile_screen.dart';
import '../company_part/edit_company_profile_screen.dart';
import '../doctor_part/edit_doctor_profile_screen.dart';
import '../patient_part/edit_patient_profile_screen.dart';

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({Key? key}) : super(key: key);

  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  late final FirebaseFirestore _firebaseFirestore;
  CollectionReference<Map<String, dynamic>>? _accountCollectionReference;
  String? _userId, _accountType;
  late final AppData _appData;
  String? _userAccountDocumentReferencePath, _userAccountDocumentReferenceId;
  Map<String, dynamic>? _userAccountJsonMap;
  Speciality? _doctorSpeciality;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _userId = _appData.getUserId(pref!)!;
      _accountType = _appData.getAccountType(pref)!;
      _getAccountData();
    });
    super.initState();
  }

  void _getAccountData() {
    AccountTypes type = AccountTypes.values.byName(_accountType.toString());
    switch (type) {
      case AccountTypes.Admin:
        _accountCollectionReference =
            _firebaseFirestore.collection(FirestoreCollections.Admins.name);
        break;
      case AccountTypes.Doctor:
        _accountCollectionReference =
            _firebaseFirestore.collection(FirestoreCollections.Doctors.name);
        break;
      case AccountTypes.Company:
        _accountCollectionReference =
            _firebaseFirestore.collection(FirestoreCollections.Companies.name);
        break;
      default:
        _accountCollectionReference =
            _firebaseFirestore.collection(FirestoreCollections.Patients.name);
    }
    _accountCollectionReference
        ?.where('userId', isEqualTo: _userId)
        .get()
        .then((snapshots) {
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
          snapshots.docs.first;
      if (queryDocumentSnapshot.exists) {
        setState(() {
          _userAccountDocumentReferencePath =
              queryDocumentSnapshot.reference.path;
          _userAccountDocumentReferenceId = queryDocumentSnapshot.reference.id;
          _userAccountJsonMap = queryDocumentSnapshot.data();
        });
        if (_userAccountJsonMap?['specialityId'] != null &&
            _userAccountJsonMap!['specialityId'].toString().trim().isNotEmpty) {
          getDoctorSpeciality();
        }
      }
    });
  }

  void getDoctorSpeciality() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(_userAccountJsonMap!['specialityId'])
        .get()
        .then((value) {
      setState(() {
        _doctorSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('الصفحة الشخصية',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.gear,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      AccountTypes type =
                          AccountTypes.values.byName(_accountType.toString());
                      switch (type) {
                        case AccountTypes.Admin:
                          return EditAdminProfileScreen(
                              adminDocumentReferencePath:
                                  _userAccountDocumentReferencePath,
                              adminDocumentReferenceId:
                                  _userAccountDocumentReferenceId,
                              admin: Admin.fromJson(_userAccountJsonMap));
                          break;
                        case AccountTypes.Doctor:
                          return EditDoctorProfileScreen(
                              doctorDocumentReferencePath:
                                  _userAccountDocumentReferencePath,
                              doctorDocumentReferenceId:
                                  _userAccountDocumentReferenceId,
                              doctor: Doctor.fromJson(_userAccountJsonMap),
                              doctorSpeciality: _doctorSpeciality);
                          break;
                        case AccountTypes.Company:
                          return EditCompanyProfileScreen(
                              companyDocumentReferencePath:
                                  _userAccountDocumentReferencePath,
                              companyDocumentReferenceId:
                                  _userAccountDocumentReferenceId,
                              company: Company.fromJson(_userAccountJsonMap));
                          break;
                        default:
                          return EditPatientProfileScreen(
                              patientDocumentReferencePath:
                                  _userAccountDocumentReferencePath,
                              patientDocumentReferenceId:
                                  _userAccountDocumentReferenceId,
                              patient: Patient.fromJson(_userAccountJsonMap));
                      }
                    })).then((value) => setState(() {
                          _getAccountData();
                        }));
                  }),
            ],
            // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
          ),
          body: Directionality(
              textDirection: TextDirection.rtl,
              child: UserProfileWidget(
                userAccountJsonMap: _userAccountJsonMap,
                doctorSpeciality: _doctorSpeciality,
              )),
        ));
  }
}

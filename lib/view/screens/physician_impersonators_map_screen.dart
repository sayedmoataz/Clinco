import 'package:clinico/view/screens/view_physician_impersonator_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../model/user_data.dart';
import '../../helper/bitmap_descriptor_generator.dart';
import '../../model/physician_impersonator.dart';

class PhysicianImpersonatorsMapScreen extends StatefulWidget {
  final String? selectedCountry;
  final bool isAdmin;

  const PhysicianImpersonatorsMapScreen(
      {Key? key, required this.selectedCountry, required this.isAdmin})
      : super(key: key);

  @override
  _PhysicianImpersonatorsMapScreenState createState() =>
      _PhysicianImpersonatorsMapScreenState();
}

class _PhysicianImpersonatorsMapScreenState
    extends State<PhysicianImpersonatorsMapScreen> {
  BitmapDescriptorGenerator? bitmapDescriptorGenerator;
  int deniedLocationPermissionRequestTimes = 1;
  LatLng? _currentPosition;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<PhysicianImpersonator> physicianImpersonators =
      <PhysicianImpersonator>[];
  List<QueryDocumentSnapshot> physicianImpersonatorDocs =
      <QueryDocumentSnapshot>[];
  FirebaseFirestore? _firebaseFirestore;
  late Query<Map<String, dynamic>>? _defaultQuery;
  Query<Map<String, dynamic>>? _fetchingQuery;
  BitmapDescriptor? physicianLocationIcon;

  @override
  void initState() {
    super.initState();
    bitmapDescriptorGenerator = BitmapDescriptorGenerator();
    _getPhysicianLocationIcon();

    _firebaseFirestore = FirebaseFirestore.instance;
    _defaultQuery = _firebaseFirestore!
        .collection(FirestoreCollections.PhysicianImpersonators.name);
    widget.isAdmin
        ? _fetchingQuery = _defaultQuery
        : _fetchingQuery = _defaultQuery?.where('selectedCountry',
            isEqualTo: widget.selectedCountry);
    _getPhysicianImpersonatorList();
    _getUserCurrentLocation();
  }

  void _getPhysicianLocationIcon() async {
    await bitmapDescriptorGenerator
        ?.getBitmapDescriptorByImagePath(
            'assets/images/physician_map_icon.jpeg')
        .then((onValue) {
      physicianLocationIcon = onValue;
    });
  }

  void _getUserCurrentLocation() async {
    Position position;
    await Geolocator.checkPermission()
        .then((LocationPermission locationPermission) async => {
              if (locationPermission == LocationPermission.denied)
                {
                  if (deniedLocationPermissionRequestTimes == 1)
                    {
                      deniedLocationPermissionRequestTimes++,
                      await Geolocator.requestPermission().then(
                          (LocationPermission locationPermission) =>
                              {_getUserCurrentLocation()})
                    }
                  else
                    {
                      Fluttertoast.showToast(
                          msg:
                              'برجاء تفعيل سماحية إستخدام التطبيق للموقع من إعدادات الهاتف!',
                          toastLength: Toast.LENGTH_LONG)
                    }
                }
              else if (locationPermission == LocationPermission.deniedForever)
                {
                  Fluttertoast.showToast(
                      msg:
                          'برجاء تفعيل سماحية إستخدام التطبيق للموقع من إعدادات الهاتف!',
                      toastLength: Toast.LENGTH_LONG)
                }
              else if (locationPermission ==
                  LocationPermission.unableToDetermine)
                {
                  Fluttertoast.showToast(
                      msg: 'التطبيق غير قادر على الوصول إلى موقعك الحالي!',
                      toastLength: Toast.LENGTH_LONG)
                }
              else
                {
                  position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high),
                  setState(() {
                    _currentPosition =
                        LatLng(position.latitude, position.longitude);
                    if (_currentPosition != null) {
                      markers.add(Marker(
                        markerId: MarkerId(_currentPosition.toString()),
                        position: _currentPosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ));
                    }
                  })
                }
            });
  }

  _getPhysicianImpersonatorList() async {
    await _fetchingQuery!.get().then((value) => {
          setState(() {
            physicianImpersonators.clear();
            physicianImpersonatorDocs.clear();
            physicianImpersonatorDocs = value.docs;
            if (physicianImpersonatorDocs.isNotEmpty) {
              physicianImpersonatorDocs.asMap().forEach((key, json) =>
                  physicianImpersonators
                      .add(PhysicianImpersonator.fromJson(json)));
              for (var physicianImpersonator in physicianImpersonators) {
                GeoPoint? clinicGeoPoint = physicianImpersonator.geoLocation;
                if (clinicGeoPoint != null) {
                  String clinicDocumentReferenceId = physicianImpersonatorDocs[
                          physicianImpersonators.indexOf(physicianImpersonator)]
                      .reference
                      .id;
                  markers.add(Marker(
                      markerId: MarkerId(clinicDocumentReferenceId),
                      position: LatLng(
                          clinicGeoPoint.latitude, clinicGeoPoint.longitude),
                      infoWindow: InfoWindow(
                          title: physicianImpersonator.name,
                          snippet: physicianImpersonator.doctorName,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewPhysicianImpersonatorProfileScreen(
                                          physicianImpersonator:
                                              physicianImpersonator)))),
                      icon: physicianLocationIcon ??
                          BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed)));
                }
              }
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('منتحلي صفة الأطباء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: _currentPosition != null ? _buildGoogleMapWidget() : null,
        ));
  }

  GoogleMap _buildGoogleMapWidget() {
    return GoogleMap(
      zoomGesturesEnabled: true,
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _currentPosition ?? const LatLng(30.0719742, 31.309779),
        zoom: 12.0,
      ),
      markers: markers,
      mapType: MapType.normal,
      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
    );
  }
}

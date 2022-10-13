import 'dart:async';

import 'package:clinico/view/screens/view_clinic_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/account_constants.dart';
import '../../constants/app_colors.dart';
import '../../helper/bitmap_descriptor_generator.dart';
import '../../model/clinic.dart';
import '../../model/user_data.dart';

class AllClinicsMap extends StatefulWidget {
  // final String specialityId, specialityDocumentPath, specialityTitle;
  bool isPatient;

  AllClinicsMap({Key? key, required this.isPatient}) : super(key: key);

  @override
  _AllClinicsMapState createState() => _AllClinicsMapState();
}

class _AllClinicsMapState extends State<AllClinicsMap> {
  BitmapDescriptorGenerator? bitmapDescriptorGenerator;
  int deniedLocationPermissionRequestTimes = 1;
  LatLng? _currentPosition;

  // GoogleMapController? mapController;
  Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<Clinic> clinics = <Clinic>[];
  List<QueryDocumentSnapshot> clinicDocs = <QueryDocumentSnapshot>[];
  FirebaseFirestore? _firebaseFirestore;
  late Query<Map<String, dynamic>>? queryClinicsRef;
  final List<String> _clinicRevealWays = AccountConstants.clinicRevealWays;

  @override
  void initState() {
    super.initState();
    bitmapDescriptorGenerator = BitmapDescriptorGenerator();
    _getUserCurrentLocation();

    _firebaseFirestore = FirebaseFirestore.instance;
    queryClinicsRef = _firebaseFirestore!
        .collection(FirestoreCollections.Clinics.name)
        .where('accountStatus', isNotEqualTo: 2);
    _getClinicList();
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

  _getClinicList() async {
    await queryClinicsRef!.get().then((value) => {
          setState(() {
            clinics.clear();
            clinicDocs.clear();
            clinicDocs = value.docs;
            if (clinicDocs.isNotEmpty) {
              clinicDocs
                  .asMap()
                  .forEach((key, json) => clinics.add(Clinic.fromJson(json)));
              for (var clinic in clinics) {
                GeoPoint? clinicGeoPoint = clinic.geoLocation;
                if (clinicGeoPoint != null) {
                  String clinicDocumentReferenceId =
                      clinicDocs[clinics.indexOf(clinic)].reference.id;
                  markers.add(Marker(
                    markerId: MarkerId(clinicDocumentReferenceId),
                    position: LatLng(
                        clinicGeoPoint.latitude, clinicGeoPoint.longitude),
                    infoWindow: InfoWindow(
                        title: clinic.name,
                        snippet: _clinicRevealWays[clinic.revealWay],
                        onTap: () {
                          if (widget.isPatient) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ViewClinicProfileScreen(
                                      clinic: clinic,
                                      clinicId: clinicDocumentReferenceId,
                                    )));
                          }
                        }),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        getRevealIcon(clinic.revealWay)),
                  ));
                }
              }
            }
          })
        });
  }

  Future<void> _goToTheLake(LatLng lt) async {
    final GoogleMapController controller = await mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: lt, zoom: 14)))
        .catchError((error) {
      print(error);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("الخريطة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          body: _currentPosition != null ? _buildGoogleMapWidget() : null,
        ));
  }

  Widget _buildGoogleMapWidget() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: GoogleMap(
            zoomGesturesEnabled: true,
            mapToolbarEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(30.0719742, 31.309779),
              zoom: 12.0,
            ),
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (controller12) {
              setState(() {
                // mapController = controller12 as Completer<GoogleMapController>;
                mapController.complete(controller12);
              });
            },
          ),
        ),
        if (clinics.isNotEmpty)
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "العيادات المتاحة",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        if (clinics.isNotEmpty)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.separated(
                itemCount: clinics.length,
                separatorBuilder: (ctx, index) => const SizedBox(
                  height: 10,
                ),
                itemBuilder: (ctx, index) => GestureDetector(
                  onTap: () => _goToTheLake(LatLng(
                      clinics[index].geoLocation!.latitude,
                      clinics[index].geoLocation!.longitude)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            width: 50,
                            height: 50,
                            image: NetworkImage(clinics[index].images!.first!),
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinics[index].name! ?? "",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                clinics[index].address! ?? "",
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  double getRevealIcon(int revealWay) {
    if (revealWay == 2) {
      return BitmapDescriptor.hueAzure;
    } else {
      return BitmapDescriptor.hueBlue;
    }
  }
}

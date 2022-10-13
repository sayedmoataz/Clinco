import 'dart:async';
import 'dart:developer';

import 'package:clinico/constants/account_constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pick_place/config/methods/camera_moving.dart';
import 'package:google_maps_pick_place/config/methods/check_permission.dart';
import 'package:google_maps_pick_place/google_maps_pick_place.dart';
import 'package:google_maps_pick_place/view/main_map/units/address_label.dart';
import 'package:google_maps_pick_place/view/main_map/units/close_map_button.dart';
import 'package:google_maps_pick_place/view/main_map/units/map_view.dart';
import 'package:google_maps_pick_place/view/main_map/units/my_location_button.dart';
import 'package:google_maps_pick_place/view/main_map/units/search_button.dart';

class CustomGoogleMapsPickPlace extends StatefulWidget {
  const CustomGoogleMapsPickPlace({
    required this.apiKey,
    this.mapLanguage = Language.arabic,
    this.getResult,
    this.initialPosition = AccountConstants.defaultInitialMapLocation,
    this.enableMyLocationButton = true,
    this.enableSearchButton = true,
    this.loader =
        const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
    this.doneButton,
    this.errorButton,
    this.zoomFactor = 5.0,
    this.markerColor = MarkerColor.red,
    Key? key,
  }) : super(key: key);

  final String apiKey;
  final Language mapLanguage;
  final Function(FullAddress)? getResult;
  final LatLng initialPosition;
  final bool enableMyLocationButton;
  final bool enableSearchButton;
  final Widget loader;
  final Widget? doneButton;
  final Widget? errorButton;
  final double zoomFactor;
  final MarkerColor markerColor;

  @override
  State<CustomGoogleMapsPickPlace> createState() =>
      _CustomGoogleMapsPickPlaceState();
}

class _CustomGoogleMapsPickPlaceState extends State<CustomGoogleMapsPickPlace> {
  bool loadingLocation = true;
  bool notConnected = true;
  bool showLabel = true;
  FullAddress fullAddress = FullAddress();
  GoogleMapController? mapController;
  Completer<GoogleMapController> completer = Completer();
  Marker marker = const Marker(
    markerId: MarkerId('1'),
  );

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(
            initialPosition: widget.initialPosition,
            marker: marker,
            zoomFactor: widget.zoomFactor,
            onMapCreated: onMapCreated,
            getLocation: getLocation,
          ),
          const CloseMapButton(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.enableMyLocationButton)
                CurrentLocationButton(getCurrentLocation: getCurrentLocation),
              if (widget.enableSearchButton)
                SearchButton(
                  addressLabelState: addressLabelState,
                  mapLanguage: widget.mapLanguage,
                  getLocation: getLocation,
                  apiKey: widget.apiKey,
                  loader: widget.loader,
                ),
            ],
          ),
          if (showLabel)
            AddressLabel(
              address: fullAddress,
              loader: widget.loader,
              notConnected: notConnected,
              loading: loadingLocation,
              done: widget.doneButton,
              mapLanguage: widget.mapLanguage,
              onTap: (fullAddress) {
                setState(() {
                  notConnected = false;
                  widget.getResult!(fullAddress);
                });
                log('${fullAddress.address} \n${fullAddress.position!.latitude} \n${fullAddress.position!.longitude}');
              },
            ),
        ],
      ),
    );
  }

  onMapCreated(GoogleMapController controller) async {
    completer.complete(controller);
    mapController = controller;
    checkPermission(getCurrentLocation());
  }

  getLocation(LatLng latLng) async {
    fullAddress.position = customPosition(latLng);
    setState(() {
      loadingLocation = true;
      notConnected = false;
    });
    List<Placemark> addressList = [];
    try {
      addressList = await geocoding.placemarkFromCoordinates(
          latLng.latitude, latLng.longitude);
      await cameraMoving(mapController!, fullAddress.position);
    } catch (e) {
      setState(() {
        notConnected = true;
        loadingLocation = false;
      });
      log('Error: $e');
      log('NotConnected: $notConnected');
    }
    final address = addressList.first;
    fullAddress.address = "${address.street}";
    marker = customMarker(
      latLng,
      getLocation,
      markerColor: widget.markerColor,
    );
    setState(() {
      loadingLocation = false;
    });
  }

  getCurrentLocation() async {
    log('GETTING LOCATION');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      fullAddress.position = await Geolocator.getCurrentPosition();
      getLocation(LatLng(
          fullAddress.position!.latitude, fullAddress.position!.longitude));
    } else {
      await Geolocator.requestPermission();
      try {
        fullAddress.position = await Geolocator.getCurrentPosition();
        getLocation(LatLng(
            fullAddress.position!.latitude, fullAddress.position!.longitude));
        log('${fullAddress.position}');
      } catch (e) {
        getLocation(LatLng(
            widget.initialPosition.latitude, widget.initialPosition.longitude));
        log('Error: $e');
      }
    }
  }

  dynamic addressLabelState() {
    setState(() {
      showLabel = !showLabel;
    });
  }
}

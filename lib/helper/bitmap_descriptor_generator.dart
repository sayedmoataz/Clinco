import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

class BitmapDescriptorGenerator {
  static final BitmapDescriptorGenerator _singleton =
      BitmapDescriptorGenerator._internal();

  factory BitmapDescriptorGenerator() => _singleton;

  BitmapDescriptorGenerator._internal();

  Future<BitmapDescriptor?> getBitmapDescriptorByImagePath(
      String imagePath) async {
    img.Image? doneImg;
    ByteData donebytes = await rootBundle.load(imagePath);
    Uint8List doneU8 = donebytes.buffer
        .asUint8List(donebytes.offsetInBytes, donebytes.lengthInBytes);
    List<int> doneListInt = doneU8.cast<int>();

    doneImg = img.decodePng(doneListInt);
    if (doneImg != null) {
      doneImg = img.copyResize(doneImg, width: 64);

      final Uint8List doneIconColorful =
          Uint8List.fromList(img.encodePng(doneImg));
      BitmapDescriptor doneBM = BitmapDescriptor.fromBytes(doneIconColorful);
      return doneBM;
    } else {
      return null;
    }
  }
}

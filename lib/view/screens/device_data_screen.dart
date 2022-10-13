import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../constants/account_constants.dart';
import '../../constants/app_colors.dart';
import '../../model/device.dart';
import '../components/alert.dart';

class DeviceDataScreen extends StatefulWidget {
  String? userId, selectedCountry;
  String devicesCategoryCollectionPath;
  bool isNewItem = true;
  String? deviceDocumentPath;
  Device? device;

  DeviceDataScreen(
      {Key? key,
      required this.userId,
      required this.selectedCountry,
      required this.devicesCategoryCollectionPath,
      required this.isNewItem,
      required this.deviceDocumentPath,
      required this.device})
      : super(key: key);

  @override
  _DeviceDataScreenState createState() => _DeviceDataScreenState();
}

class _DeviceDataScreenState extends State<DeviceDataScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Device? _device;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Reference deviceImagesFirebaseStorageReference;
  late List<dynamic> initialImageList;
  List<dynamic> currentImageList = [];
  bool _isAvailableForPatient = false;

  @override
  void initState() {
    if (!widget.isNewItem) {
      _device = widget.device;
      if (_device?.images != null) {
        initialImageList = List.unmodifiable(_device!.images!);
        currentImageList.addAll(initialImageList);
      }
      if (_device != null) {
        _isAvailableForPatient = _device!.isAvailableForPatient;
      }
    } else {
      initialImageList = List.unmodifiable([]);
      _device = Device(widget.userId, null, widget.selectedCountry, null, 0,
          null, null, null, <dynamic>[], false);
    }
    deviceImagesFirebaseStorageReference =
        FirebaseStorage.instance.ref('${_device!.createdBy}/deviceImages');
    super.initState();
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(getToolbarTitle(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await saveDeviceData(context, widget.isNewItem, dialog);
                },
              ),
            ],
          ),
          body: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: ListView(
                children: [
                  Form(
                      key: formstate,
                      child: Column(children: [
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _device?.name ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 100) {
                                return 'أقصى عدد للأحرف هو ١٠٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _device?.name =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "الإسم",
                                prefixIcon: Icon(Icons.title))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _device?.type ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 100) {
                                return 'أقصى عدد للأحرف هو ١٠٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _device?.type =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "النوع",
                                prefixIcon: Icon(Icons.title))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _device?.manufacture ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 100) {
                                return 'أقصى عدد للأحرف هو ١٠٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _device?.manufacture =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "المنشأ",
                                prefixIcon: Icon(Icons.title))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.multiline,
                            initialValue: _device?.description ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 300) {
                                return 'أقصى عدد للأحرف هو ٣٠٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _device?.description =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 300,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "الوصف",
                                prefixIcon: Icon(Icons.title))),
                        TextFormField(
                            enableInteractiveSelection: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: (_device?.price ?? '').toString(),
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 16) {
                                return 'أقصى عدد للأحرف هو ١٦';
                              }
                              if (text.isEmpty) {
                                return 'أقل عدد للأحرف هو ١';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _device?.price = int.parse(val.toString().trim());
                            },
                            maxLength: 12,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText:
                                    'السعر (${_device?.selectedCountry != null ? AccountConstants.getPriceCurrencyByCountry(_device!.selectedCountry!) : ''})',
                                prefixIcon: const Icon(Icons.attach_money))),
                        TextFormField(
                            enableInteractiveSelection: false,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: (_device?.warranty ?? '').toString(),
                            onSaved: (val) {
                              String value = val.toString().trim();
                              if (value.isEmpty) {
                                _device?.warranty = 0;
                              } else {
                                _device?.warranty = int.parse(value);
                              }
                            },
                            maxLength: 12,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'مدة الضمان (بالأشهر)',
                                prefixIcon:
                                    Icon(FontAwesomeIcons.calendarDay))),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              activeColor: primaryColor,
                              value: _isAvailableForPatient,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    _isAvailableForPatient = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'الجهاز متاح للمرضى',
                              style: TextStyle(
                                  fontSize: 17.0, color: primaryColor),
                            ), //Text
                          ], //<Widget>[]
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: const Text('صور الجهاز',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: Row(children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: ReorderableListView(
                                    scrollDirection: Axis.horizontal,
                                    children: currentImageList
                                        .map((item) => Container(
                                              key: Key("$item"),
                                              margin: const EdgeInsets.only(
                                                  left: 1, right: 1),
                                              width: 80,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15.0)),
                                                image: DecorationImage(
                                                  image: getImageByItem(item),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 30,
                                                  color: Colors.black,
                                                ),
                                                iconSize: 5,
                                                onPressed: () {
                                                  if (currentImageList.length <
                                                      2) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "يحب أن يكون للجهاز على الأقل صورة واحدة!");
                                                    return;
                                                  }
                                                  showDialog<String>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        'حذف صورة',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                      ),
                                                      content: const Text(
                                                          'هل متأكد أنك تريد حذف هذه الصورة',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          textDirection: ui
                                                              .TextDirection
                                                              .rtl),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Cancel'),
                                                          child:
                                                              const Text('لا'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context, 'Ok');
                                                            setState(() {
                                                              currentImageList
                                                                  .remove(item);
                                                            });
                                                          },
                                                          child:
                                                              const Text('نعم'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ))
                                        .toList(),
                                    onReorder: (int start, int current) {
                                      if (start < current) {
                                        int end = current - 1;
                                        String startItem =
                                            currentImageList[start];
                                        int i = 0;
                                        int local = start;
                                        do {
                                          currentImageList[local] =
                                              currentImageList[++local];
                                          i++;
                                        } while (i < end - start);
                                        currentImageList[end] = startItem;
                                      } else if (start > current) {
                                        String startItem =
                                            currentImageList[start];
                                        for (int i = start; i > current; i--) {
                                          currentImageList[i] =
                                              currentImageList[i - 1];
                                        }
                                        currentImageList[current] = startItem;
                                      }
                                      setState(() {});
                                    }),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 1, right: 1),
                                    width: 80,
                                    height: double.infinity,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                        color: Colors.black45),
                                    child: IconButton(
                                      iconSize: 40,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (currentImageList.length > 3) {
                                          Fluttertoast.showToast(
                                              msg: "أقصى عدد للصور هو ٤");
                                          return;
                                        }
                                        _showBottomSheet(context, dialog);
                                      },
                                    ),
                                  ))
                            ])),
                      ]))
                ],
              )),
        ));
  }

  getImageByItem(String image) => Utils().isNetworkUrl(image)
      ? NetworkImage(image)
      : FileImage(File(image));

  String getToolbarTitle() =>
      widget.isNewItem ? 'إضافة جهاز جديد' : 'تعديل بيانات الجهاز';

  _showBottomSheet(context, LoadingIndicator dialog) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 210,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إختيار صورة الجهاز",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    InkWell(
                      onTap: () async {
                        var picked = await ImagePicker()
                            .getImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            currentImageList.add(picked.path);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_outlined,
                                size: 30,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "من المعرض",
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                              )
                            ],
                          )),
                    ),
                    InkWell(
                      onTap: () async {
                        var picked = await ImagePicker()
                            .getImage(source: ImageSource.camera);
                        if (picked != null) {
                          setState(() {
                            currentImageList.add(picked.path);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.camera,
                                size: 30,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "من الكاميرا",
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ));
        });
  }

  saveDeviceData(context, isNew, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (currentImageList.isEmpty) {
        Fluttertoast.showToast(msg: "أضف على الأقل صورة واحدة للجهاز!");
        return;
      }
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            dialogContext = context;
            return dialog;
          });
      formData.save();
      _device?.isAvailableForPatient = _isAvailableForPatient;
      await getReadyImageList()
          .then((imageList) => _device!.images = imageList);
      DocumentReference deviceDocumentRef;
      if (isNew) {
        deviceDocumentRef = _firebaseFirestore
            .collection(widget.devicesCategoryCollectionPath)
            .doc();
      } else {
        deviceDocumentRef = _firebaseFirestore.doc(widget.deviceDocumentPath!);
      }
      await deviceDocumentRef.set(_device?.toJson()).then((value) {
        Fluttertoast.showToast(msg: "تم الحفظ بنجاح");
        Navigator.pop(dialogContext!);
        Navigator.pop(context);
      }).catchError((error) {
        Fluttertoast.showToast(msg: "حدث خطأ ما!");
      });
    }
  }

  Future<List> getReadyImageList() async {
    for (var imageUrl in initialImageList) {
      if (!currentImageList.contains(imageUrl)) {
        await _firebaseStorage.refFromURL(imageUrl).delete();
      }
    }
    List<dynamic> readyImageList = [];
    for (var imagePath in currentImageList) {
      if (Utils().isNetworkUrl(imagePath)) {
        readyImageList.add(imagePath);
      } else {
        File file = File(imagePath);
        String randomDigits = Random().nextInt(10000000).toString();
        var imageName = randomDigits + basename(imagePath);
        Reference ref = deviceImagesFirebaseStorageReference.child(imageName);
        await ref.putFile(file);
        await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
              readyImageList.add(uploadedImageUrl);
            }));
      }
    }
    return readyImageList;
  }
}

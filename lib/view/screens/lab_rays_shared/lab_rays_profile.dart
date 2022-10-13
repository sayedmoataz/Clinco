import 'dart:io';

import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/components.dart';

class LabRaysProfile extends StatefulWidget {
  bool isLab;

  LabRaysProfile({Key? key, required this.isLab}) : super(key: key);

  @override
  State<LabRaysProfile> createState() => _LabRaysProfileState();
}

class _LabRaysProfileState extends State<LabRaysProfile> {
  String imageUrl = "";
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController description = TextEditingController();
  bool pageIsStarting = false;
  bool updateUserDataIsLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  getUserData() async {
    setState(() {
      pageIsStarting = true;
    });
    await FirebaseFirestore.instance
        .collection(widget.isLab ? "Labs" : "RaysCenter")
        .doc(user!.uid)
        .get()
        .then((value) {
      name.text = value["name"];
      email.text = value["email"];
      if (value.data()!.containsKey("phoneNumber"))
        number.text = value["phoneNumber"];
      if (value.data()!.containsKey("address")) address.text = value["address"];
      if (value.data()!.containsKey("description"))
        description.text = value["description"];
      if (value.data()!.containsKey("image")) imageUrl = value["image"];
    }).catchError((error) {
      Fluttertoast.showToast(msg: "حدث خطأ حاول مرة اخرى");
    });
    setState(() {
      pageIsStarting = false;
    });
  }

  updateUserData() async {
    String url = "";
    setState(() {
      updateUserDataIsLoading = true;
    });
    if (_image != null) {
      url = await uploadImage(_image!);
    }
    await FirebaseFirestore.instance
        .collection(widget.isLab ? "Labs" : "RaysCenter")
        .doc(user!.uid)
        .update({
      "phoneNumber": number.text,
      "address": address.text,
      "description": description.text,
      if (url != "") "image": url,
    }).then((value) {
      Fluttertoast.showToast(msg: "تم تعديل البيانات بنجاح");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "حدث خطأ حاول مرة اخرى");
    });
    setState(() {
      updateUserDataIsLoading = false;
    });
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();

  void getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    var ref =
        FirebaseStorage.instance.ref().child('validation').child(user!.uid);
    await ref.putFile(image);
    final url = await ref.getDownloadURL();
    return url;
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "الحساب الشخصي",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            updateUserDataIsLoading
                ? const CupertinoActivityIndicator()
                : TextButton(
                    onPressed: () => updateUserData(),
                    child: Text(
                      "حفظ البيانات",
                      style: TextStyle(
                          color: AppColors.appPrimaryColor, fontSize: 17),
                    )),
          ],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: pageIsStarting
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        radius: 41,
                        backgroundColor: AppColors.appPrimaryColor,
                        child: ClipOval(
                          child: SizedBox(
                              width: 80,
                              height: 80,
                              child: _image != null
                                  ? Image.file(_image!, fit: BoxFit.cover)
                                  : imageUrl != ""
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          "assets/images/user_avatar.png")),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () => getImage(),
                        child: Text(
                          "تعديل",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  color: AppColors.appPrimaryColor,
                                  fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text(
                              "اسم المستحدم:",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: defaultTextFormField(
                              context: context,
                              enabled: false,
                              controller: name,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text(
                              "البريد الالكترونى:",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: defaultTextFormField(
                              context: context,
                              enabled: false,
                              controller: email,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text(
                              "رقم الهاتف:",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: defaultTextFormField(
                              context: context,
                              borderColor: Colors.grey[300]!,
                              controller: number,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: Text(
                              widget.isLab ? "عنوان المعمل:" : "عنوان المركز:",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: defaultTextFormField(
                              context: context,
                              borderColor: Colors.grey[300]!,
                              controller: address,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: Text(
                              widget.isLab
                                  ? "تفاصيل المعمل:"
                                  : "تفاصيل المركز:",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: defaultTextFormField(
                              context: context,
                              borderColor: Colors.grey[300]!,
                              controller: description,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

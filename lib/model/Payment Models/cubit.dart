import 'dart:convert';


import 'package:clinico/helper/shared_preferences.dart';
import 'package:clinico/model/Payment%20Models/cache_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import 'auth_request.dart';
import 'constants.dart';
import 'kiosk.dart';
import 'order_regist.dart';
import 'payment_key.dart';
import 'states.dart';
import 'track_payment.dart';



class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  var paymentAPI = "https://accept.paymob.com/api/";

  bool isLoadingState = false;
  void loadingScreens(bool value) {
    isLoadingState = value;
    emit(IsLoadingState());
  }


  AuthRequest? authRequest;
  Future getAuthToken(String fname,String lname,String phone,String email, String PriceinCents,String id,bool isKiosk, context) async{
    loadingScreens(true);
    emit(PaymentGetAuthTokenLoadingState());
    var url = Uri.parse('${paymentAPI}auth/tokens');
    var paymentData = json.encode({ 'api_key' : paymobApiKey});
    var paymentHeader = { 'Accept': 'application/json','Content-Type': 'application/json'};
    await http.post(url,body: paymentData,headers: paymentHeader).then((value){
      authRequest = AuthRequest.fromJson(jsonDecode(value.body));
      authToken =  authRequest!.token!;
      CacheHelper.putData(key: "authToken", value: authToken);
      if (kDebugMode) {
        print("authToken value is : $authToken");
      }
      getOrderID(PriceinCents, fname,lname,phone,email,id, isKiosk, context);
      emit(PaymentGetAuthTokenSuccessState());
    }).catchError((error){
        if (kDebugMode) {
          print("getAuthToken error is : $error");
        }
        loadingScreens(false);
      emit(PaymentGetAuthTokenFailedState());
    });

  }

  OrderRegis? orderRegis;
  Future getOrderID(String priceCents, String firstName,String lastName,String phoneNumber,String emailAddress,String id,bool isKiosk, BuildContext context ) async{
    emit(PaymentGetOrderIDLoadingState());
    var url = Uri.parse('${paymentAPI}ecommerce/orders');
    var paymentData = json.encode({ 
      'auth_token' : authToken,
      "delivery_needed": "false",
      "amount_cents": priceCents.toString(),
      "currency": "EGP",
      "items": []
    });
    var paymentHeader = { 'Accept': 'application/json','Content-Type': 'application/json'};
    await http.post(url,body: paymentData,headers: paymentHeader).then((value){
      orderRegis = OrderRegis.fromJson(jsonDecode(value.body));
      orderID =  orderRegis!.id.toString();
      CacheHelper.putData(key: "orderID", value: orderID);
      if (kDebugMode){
        print("orderID value is : $orderID");
      }
      getPaymentKey(
        fName: firstName,
        lName: lastName,
        phone: phoneNumber,
        email: emailAddress,
        isKiosk: isKiosk,
        IntegrationID: id ,
        context: context
      );
      emit(PaymentGetOrderIDSuccessState());
    }).catchError((error){
      if (kDebugMode){
        print("getOrderID error is : $error");
      }
      loadingScreens(false);
      emit(PaymentGetOrderIDFailedState());
    });
  }

  PaymentKey? paymentKey;
  Future getPaymentKey({required String fName,required String lName,required String phone,required String email, required bool isKiosk,required String IntegrationID,required BuildContext context}) async{
    emit(PaymentGetPaymentTokenLoadingState());
    var url = Uri.parse('${paymentAPI}acceptance/payment_keys');
    var paymentData = json.encode({
      "auth_token": authToken,
      "amount_cents": priceInCents,
      "expiration": 86400, // 24 hour
      "order_id": orderID,
      "billing_data": {
        "first_name": fName,
        "last_name": lName,
        "phone_number": phone,
        "email": email,
        "country": "NA",
        "building": "NA",
        "city": "NA",
        "floor": "NA",
        "apartment": "NA",
        "street": "NA"
      },
      "currency": "EGP",
      "integration_id": IntegrationID
    });
    var paymentHeader = { 'Accept': 'application/json','Content-Type': 'application/json'};
    await http.post(url,body: paymentData,headers: paymentHeader).then((value){
      paymentKey = PaymentKey.fromJson(jsonDecode(value.body));
      paymentToken =  paymentKey!.token!;
      debugPrint("paymentToken value is : $paymentToken");
      if (isKiosk == false ) {
        launchUrl(Uri.parse(iFrameLink.toString()));
        getOrderStatus();
        loadingScreens(false);
      }else{
        getKioskKey(paymentToken, context);
      }
      emit(PaymentGetPaymentTokenSuccessState());
    }).catchError((error){
      if (kDebugMode){
        print("getPaymentKey error is : $error");
      }
      loadingScreens(false);
      emit(PaymentGetPaymentTokenFailedState());
    });
  }

  Kiosk? kiosk;
  Future getKioskKey(String paymentTokenKey, BuildContext context) async{
    emit(PaymentGetKioskTokenLoadingState());
    var url = Uri.parse('${paymentAPI}acceptance/payments/pay');
    var paymentData = json.encode({
      "source": {
        "identifier": "AGGREGATOR",
        "subtype": "AGGREGATOR"
      },
      "payment_token": paymentTokenKey
    });
    var paymentHeader = { 'Accept': 'application/json','Content-Type': 'application/json'};
    await http.post(url,body: paymentData,headers: paymentHeader).then((value){
      kiosk = Kiosk.fromJson(jsonDecode(value.body));
      kioskID =  kiosk!.id.toString();
      if (kDebugMode) {
        print("kioskID value is : $kioskID");
      }
      getOrderStatus();
      loadingScreens(false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0)),
            child: SizedBox(
              height: 250,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("برجاء التوجه الي اقرب فرع/ماكينة\n (أمان او مصاري او ممكن او سداد) \nواسأل عن\ (مدفوعات اكسبت) \nوأخبرهم بالرقم المرجعي ",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      const Text("يمكنك الدفع خلال 24 ساعه من الآن",style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text("الرقم المرجعي الخاص بك $kioskID",style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      TextButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'إكمال الحجز',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      ],
                    ),
                  ),
              ),
              ),
            );
          });

      emit(PaymentGetKioskTokenSuccessState());
    }).catchError((error){
        if (kDebugMode) {
          print("getPaymentKey error is : $error");
        }
        loadingScreens(false);
      emit(PaymentGetKioskTokenFailedState());
    });
  }

  TrackTransaction? trackTransaction;
  Future getOrderStatus() async{
    emit(TrackingPaymentLoadingState());
    var url = Uri.parse('${paymentAPI}acceptance/transactions/${CacheHelper.getData(key: "orderID")}');
    var paymentHeader = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${CacheHelper.getData(key: "authToken")}'
    };
    await http.post(url,headers: paymentHeader).then((value){
      trackTransaction = TrackTransaction.fromJson(jsonDecode(value.body));
      pending =  trackTransaction!.pending.toString();
      success = trackTransaction!.success.toString();
      if (kDebugMode) {
        print("pending value is : $pending");
        print("success value is : $success");
      }
      emit(TrackingPaymentSuccessState());
    }).catchError((error){
      if (kDebugMode) {
        print("getOrderStatus error is : $error");
      }
      emit(TrackingPaymentFailedState());
    });
  }
}

import 'package:clinico/model/Payment%20Models/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWeView extends StatelessWidget {
  const PaymentWeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading:  Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: (){
                Navigator.pushNamed(context, "/patientHomeScreen");
              },
              child: const Icon(Icons.exit_to_app),
            ),
          ),
        ),
        body: WebView(
          initialUrl: iFrameLink.toString(),
        ),
      ),
    );
  }
}

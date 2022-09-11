
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:insta_look/localDb/firebase_services.dart';

class Payment extends StatefulWidget {
  // const Payment({Key? key}) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  var paymentData;
  var data;

  makePayment(var price) async{
    try{
      paymentData=await createPayment(price,'AED');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentData['client_secret'],
              // googlePay: true,
              // applePay: true,
              style: ThemeMode.dark,
              merchantCountryCode: 'US',
              merchantDisplayName: 'Mazhar Nadeem'
          ));
      displayPaymentSheet();

    }catch(e){
      print('Make Payment Exception = ${e.toString()}');
    }
  }

  displayPaymentSheet() async{
    try{
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(clientSecret: paymentData['client_secret'],
              confirmPayment: true)
      );
      setState(() {
        paymentData=null;
      });
      FirebaseServices().updateData();


      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paid Successfully')));
      Navigator.pop(context);

    } on StripeException catch(e){
      print('Stripe Exception = $e');
      showDialog(context: context, builder: (_)=>AlertDialog(
        content: Text('Cancelled'),
      ));
    }

  }


  createPayment(String amount, String currency) async {
    try{
      var body={
        'amount': calculateAmount(amount),
        'currency':currency,
        'payment_method_types[]': 'card'
      };
      var response=await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization' :'Bearer sk_test_51LLotEC7iEn7tJEBlMVHM35CJ4zOyc494V2EfCzbUQ5icOoLo1ckPCEjNVyUFpGQySULnONPEhhDp5dsO9cPNtQc00r68Wn39i',
            'Content-Type' : 'application/x-www-form-urlencoded'
          }
      );
      data=jsonDecode(response.body.toString());
      return data;

    }catch(e){
      print('Exception = ${e.toString()}}');
    }




  }

  calculateAmount(String amount) {
    var price=int.parse(amount)*100;
    return price.toString();
  }


}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:insta_look/localDb/firebase_services.dart';
import 'package:insta_look/localDb/payment.dart';
import 'package:insta_look/pages/instapayment.dart';






class UserSideBaneeer extends StatefulWidget {
   UserSideBaneeer({ Key? key }) : super(key: key);

  @override
  State<UserSideBaneeer> createState() => _UserSideBaneeerState();
}

class _UserSideBaneeerState extends State<UserSideBaneeer> {
  @override
  Widget build(BuildContext context) {
    return IssueListApi();
  }
}





class IssueListApi extends StatefulWidget {
  IssueListApi({Key? key}) : super(key: key);

  @override
  State<IssueListApi> createState() => _IssueListApiState();
}
enum radiochacter { terms, sec , third}
class _IssueListApiState extends State<IssueListApi> {

  
   radiochacter ? _character =radiochacter.sec;
   // radiochacter ? _character =radiochacter .terms;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color.fromARGB(230, 0, 0, 0),
    
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
        
                 
              Column(children: [
      
                SizedBox(height: 30,),
                    Row(children: [
                        Container(
                       // color: Colors.black,
                          height: 30,
                          width: 30,
                           decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(18.0) , 
              ),
            ),
          
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    SizedBox(width: 5,),
                    GestureDetector(
                      onTap: (){ Navigator.pop(context, );},
                      
                      child: Icon(Icons.arrow_back_ios , color: Colors.white,  size: 16,)),
                      
                  ],
                  
                ),
                
                
                    
                    
                      ),
                    ],)
          
              ],),
           
              
              SizedBox(height: 30,),
        
              Container(
                height: 250,
                width: double.infinity,
                
                child: Image.asset("images/landscape.jpg",fit: BoxFit.fill,)

              
              ),
              SizedBox(height: 10,),
               Column(children: [
                  Row(children: [
                    
                    Icon(Icons.done, color: Colors.green,),
                  Text("Giving you the best look of your insta page",style: TextStyle(color: Colors.white, fontSize: 15,),),
        
                 
        
        
        
                  ],),
                  Row(children: [
                    
                    Icon(Icons.done, color: Colors.green,),
                  Text("Providing extensive filter inventory to match editing needs",style: TextStyle(color: Colors.white, fontSize: 15,),),
        
                 
        
        
        
                  ],),
                  Theme(
                  data: ThemeData(
                    //here change to your color 
                    unselectedWidgetColor: Colors.white,
                  ),
                  child:     Column(children: [
                    ListTile(
                      title: const Text("Monthly 37/AED",style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                      leading: Radio<radiochacter>(
                        value: radiochacter.sec,
                        groupValue: _character,
                        onChanged: (radiochacter? value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                     ListTile(
                      title: const Text("Yearly 249/AED",style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                      leading: Radio

                      <radiochacter>(


                        value: radiochacter.third,

                        groupValue: _character,
                        onChanged: (radiochacter? value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),

                              ],)

                            ),





                             ],),
                     Padding(
                 padding: const EdgeInsets.only(left: 40,right: 40),
                 child: MaterialButton(
                 color: Colors.blue,
                 minWidth: double.infinity,
                 height: 50,
                 onPressed: () async{

                   if(_character?.index==1){
                     makePayment('37');
                   }
                   if(_character?.index==2){
                     makePayment('249');
                   }


                   // Navigator.push(context, MaterialPageRoute(builder: (context)=>  CartPage ()));// signup


                 },
                 shape: RoundedRectangleBorder(
                   side: BorderSide(
                     color: Colors.blue,
                   ),
                    borderRadius: BorderRadius.circular(16),
                 ),
                 
                   child:   Text("Continue",style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                 
      
      
                 ),
               ),
               SizedBox(height: 20,),
             
            ],
          ),
        ),
      ),
    );
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



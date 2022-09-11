import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseServices {

  writeData(var email,var id) async {
    //Reference to Firebase document
    var doc=FirebaseFirestore.instance.collection('payment').doc();

    final data={
      'doc_id':doc.id,
      'user_id':id,
      'email': email,
      'payment': 'pending',
    };
    //Create document and write data to Firestore
    await doc.set(data);
  }

  readData() async {
    var data=[];


          // Read one document from firebase
          // Here i have made query on select document which equals to id..Here only 1 document match
          // As it match only on document for that reason i directly use (docs[0])
    var user=FirebaseAuth.instance.currentUser;
    var doc=await FirebaseFirestore.instance.collection('payment').where('user_id',isEqualTo: user?.uid).get();

    var doc1=doc.docs[0];
    return doc1;
  }

  updateData() async{
    var user=FirebaseAuth.instance.currentUser;

          // Here we Read Data from firestore for getting docId by Query
    var docData=await FirebaseFirestore.instance.collection('payment').where('user_id',isEqualTo: user?.uid).get();
    var docId=docData.docs[0]['doc_id'];

    var data={
      'payment': 'approved',};
            // Update document by using Document Id
    FirebaseFirestore.instance.collection('payment').doc(docId).update(data);
  }





}
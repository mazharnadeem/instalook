import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_look/localDb/database.dart';
import 'package:insta_look/localDb/firebase_services.dart';
import 'package:insta_look/pages/Banner_user_side.dart';
import 'package:share_plus/share_plus.dart';

class SaveCaresol extends StatefulWidget {
  final List<String> urlImages;
  SaveCaresol({Key? key, required this.urlImages}) : super(key: key);

  @override
  State<SaveCaresol> createState() => _SaveCaresolState();
}

class _SaveCaresolState extends State<SaveCaresol> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text('Instalook'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 55,
            ),
            CarouselSlider(
              items: widget.urlImages
                  .map((item) => Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(const Base64Decoder().convert(great[int.parse(item)].image64bit.toString()),height: 600,width: 1000,fit: BoxFit.fill,),
                        ),
                      ))
                  .toList(),
              options: CarouselOptions(
                height: 500,
                autoPlay: true,
                enableInfiniteScroll: false,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
              ),
            ),
            SizedBox(
              height: 55,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (BuildContext context) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          textStyle: TextStyle(
                              //fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      onPressed: () async {

                        var data=await  FirebaseServices().readData();
                        if(data['payment']=='pending'){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      IssueListApi()));
                        }
                        else{
                          _onShare(context);

                        }

                      },
                      child: const Text(
                        'Post Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    List<String>? image=[];
    var img;
    var xyz;
    var imgg;

    var index=widget.urlImages;
    for(int i=0;i<widget.urlImages.length;i++){
      var ind=int.parse(index[i]);
      img=great[ind].image64bit.toString();
      xyz=Base64Decoder().convert(img);
      imgg=await DatabaseHelper().openImage(xyz,i);
      image!.add(imgg);
    }


    var pathList = <String>[];
    int count = 0;
    if (pathList.isNotEmpty) {
      final files = await widget.urlImages
          .map<String>((file) => file.toString())
          .toList();

      await Share.shareFiles(widget.urlImages,
        // text: text,
        // subject: subject,
        // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
      );
    } else {

      await Share.shareFiles(
        image!,
        // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
      );
    }
  }


}

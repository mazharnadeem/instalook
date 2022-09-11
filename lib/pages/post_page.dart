import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_look/localDb/database.dart';
import 'package:insta_look/localDb/firebase_services.dart';
import 'package:insta_look/pages/instapayment.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'Banner_user_side.dart';

class PreviewDart extends StatefulWidget {
  final List<String> urlImages;
  const PreviewDart({Key? key, required this.urlImages}) : super(key: key);

  @override
  State<PreviewDart> createState() => _PreviewDartState();
}

class _PreviewDartState extends State<PreviewDart> {
  String text = '';
  String subject = '';
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(children: [
              SizedBox(
                height: 180,
              ),
              CarouselSlider(
                items: widget.urlImages
                    .map((item) {
                      // Fluttertoast.showToast(msg: '$item');
                      var itm=int.parse(item);
                  return Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // child: Image.file(
                      //   File(item),
                      //   fit: BoxFit.fill,
                      //   width: 1000,
                      //   height: 600,
                      // ),
                      // child: Image.memory(great[0].image64bit,height: 600,width: 1000,fit: BoxFit.fill,),
                      child: Image.memory(const Base64Decoder().convert(great[itm].image64bit.toString()),height: 600,width: 1000,fit: BoxFit.fill,),
                    ),
                  );
                } ).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Share text:',
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: 'Enter some text and/or link to share',
                      ),
                      maxLines: 2,
                      onChanged: (String value) =>
                          // setState(() {
                        text = value,
                      // }),
                    ),
                    TextField(
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Share subject:',
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: 'Enter subject to share (optional)',
                      ),
                      maxLines: 2,
                      onChanged: (String value) =>
                          // setState(() {
                        subject = value,
                      // }),,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 48.0)),
                    Builder(
                      builder: (BuildContext context) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                              ),
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

                                // text.isEmpty ? null : () => _onShare(context);
                              },

                              child: const Text('Post'),
                            ),

                          ],
                        );
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 12.0)),
                  ],
                ),
              )
            ]),
          ),
        ));
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
    if (pathList.isNotEmpty) {

      final files = await widget.urlImages
          .map<String>((file) => file.toString())
          .toList();

      await Share.shareFiles(widget.urlImages,
          text: text,
          subject: subject,
          // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
          );
    } else {


      await Share.shareFiles(
          image!,
        text: text,
        subject: subject,
        // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
      );

    }
  }
}

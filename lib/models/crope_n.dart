
import 'dart:convert';
import 'dart:ui';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_look/add_photos.dart';
import 'package:insta_look/authentications/profile.dart';
import 'package:insta_look/localDb/database.dart';
import 'package:insta_look/localDb/database_handler.dart';
import 'package:insta_look/localDb/user_model.dart';
import 'package:insta_look/localDb/user_repo.dart';
import 'package:insta_look/models/profile_model.dart';
import 'package:insta_look/models/save_caroseul.dart';
import 'package:insta_look/models/save_filtered_images.dart';
import 'package:insta_look/post_page.dart';
import 'package:insta_look/small_navigation.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/files.dart';
import 'package:insta_look/Banner_user_side.dart';
import 'package:insta_look/pages/instapayment.dart';
import 'package:path/path.dart' as Path;
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';

var pickedImage;

class Newcroperfollow extends StatefulWidget {
  const Newcroperfollow({Key? key}) : super(key: key);

  @override
  State<Newcroperfollow> createState() => _NewcroperfollowState();
}

class _NewcroperfollowState extends State<Newcroperfollow> {
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // theme: ThemeData.light().copyWith(primaryColor: Colors.deepOrange),
      body: MyHomePage(
        title: 'Instalook croper',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppState {
  free,
  picked,
  cropped,
  filter,
}

List<File> savedImages = <File>[];
File? imageFile;

class _MyHomePageState extends State<MyHomePage> {
  List<Picture> datas = [];
  Future<File>? imgFile;
  Image? image;
  DatabaseHandler? databaseHandler;
  List<Picture>? imagess;
  bool uploading = false;
  double val = 0;
  CollectionReference? imgRef;
  firebase_storage.Reference? ref;
  var pList;
  Future? imageload;
  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
    state = AppState.free;
    imgRef = FirebaseFirestore.instance.collection('imageURLs');
    imagess = [];
    databaseHandler = DatabaseHandler();
    pList = DatabaseHelper().getAllProfile();
    print('Init State = ${pList}');
    imageload=_getImages();
    getFromUserpic();

  }
  _getImages() async{
    return await DatabaseHelper().getAllProfile();

  }

  // List<File> SelectedImages = <File>[];
  List<MyImages> MyimagesList = <MyImages>[];
  int _selectedIndex = 0;
  final controller = DragSelectGridViewController();

  Future uploadFile() async {
    int i = 1;

    for (var img in savedImages) {
      setState(() {
        val = i / savedImages.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(img.path)}');
      await ref!.putFile(img).whenComplete(() async {
        await ref!.getDownloadURL().then((value) {
          imgRef!.add({'url': value});
          i++;
        });
      });
    }
  }

  // Widget builderGrid() {
  //   return DragSelectGridView(
  //       gridController: controller,
  //       itemCount: savedImages.length,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisSpacing: 8, crossAxisCount: 3, mainAxisSpacing: 8),
  //       itemBuilder: (context, index, isSelected) {
  //         if (isSelected) {
  //           if (MyimagesList.isNotEmpty &&
  //               MyimagesList.where((element) => element.index == index)
  //                       .length ==
  //                   0) {
  //             MyimagesList.add(
  //                 new MyImages(savedImages[index], isSelected, index));
  //           } else if (MyimagesList.isEmpty) {
  //             MyimagesList.add(
  //                 new MyImages(savedImages[index], isSelected, index));
  //           }
  //         } else if (savedImages != null && !isSelected) {
  //           // MyimagesList.remove(value);
  //         }
  //         savedImages = savedImages;
  //         if (isSelected == false) {
  //           return Stack(overflow: Overflow.visible, children: [
  //             Positioned(
  //               child: Image.file(
  //                 File(savedImages[index].path).absolute,
  //                 fit: BoxFit.cover,
  //                 width: 150,
  //                 height: 150,
  //               ),
  //             ),
  //             Positioned(
  //                 top: 0,
  //                 right: 0,
  //                 left: 90,
  //                 child: IconButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         savedImages.removeAt(index);
  //                       });
  //                     },
  //                     icon: Icon(Icons.delete, color: Colors.red))),
  //           ]);
  //         }
  //
  //         return isSelected
  //             ? SelectableItemWidget(
  //                 url: savedImages[index].path, IsSelected: isSelected)
  //             : Container();
  //       });
  // }







  // Widget builderGrid1() {
  //   return DragSelectGridView(
  //       gridController: controller,
  //       itemCount: savedImages.length,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisSpacing: 8, crossAxisCount: 3, mainAxisSpacing: 8),
  //       itemBuilder: (context, index, isSelected) {
  //         if (isSelected) {
  //           if (MyimagesList.isNotEmpty &&
  //               MyimagesList.where((element) => element.index == index)
  //                   .length ==
  //                   0) {
  //             MyimagesList.add(
  //                 new MyImages(savedImages[index], isSelected, index));
  //           } else if (MyimagesList.isEmpty) {
  //             MyimagesList.add(
  //                 new MyImages(savedImages[index], isSelected, index));
  //           }
  //         } else if (savedImages != null && !isSelected) {
  //           // MyimagesList.remove(value);
  //         }
  //         savedImages = savedImages;
  //         if (isSelected == false) {
  //           return Stack(overflow: Overflow.visible, children: [
  //             Positioned(
  //               child: Image.file(
  //                 File(savedImages[index].path).absolute,
  //                 fit: BoxFit.cover,
  //                 width: 150,
  //                 height: 150,
  //               ),
  //             ),
  //             Positioned(
  //                 top: 0,
  //                 right: 0,
  //                 left: 90,
  //                 child: IconButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         savedImages.removeAt(index);
  //                       });
  //                     },
  //                     icon: Icon(Icons.delete, color: Colors.red))),
  //           ]);
  //         }
  //
  //         return isSelected
  //             ? SelectableItemWidget(
  //             url: savedImages[index].path, IsSelected: isSelected)
  //             : Container();
  //       });
  // }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  void scheduleRebuild() => setState(() {});
  late AppState state;

  @override
  Widget build(BuildContext context) {
    final isSelect = controller.value.isSelecting;
    var AssetSelected = controller.value.selectedIndexes.map<String>((index) {
      return index.toString();
    }).toList();
    final text = isSelect ? '${controller.value.amount} Selected image' : ('Instalook');
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          leading: isSelect ? CloseButton() : Container(),
          title: Text(
            text.toString(),
          ),

          // title: Text('aestheticpie'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          // leading: isSelect ? CloseButton() : Container(),
          // title: Text(text.toString()),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 90, right: 90),
                      child: MaterialButton(
                        //  color: Colors.white,
                        minWidth: 30,
                        height: 50,

                        onPressed: () async{
                          if (imageFile == null || imageFile != null) {
                            await _pickImage();
                          }


                            // imageFile;
                             await _showMyDialog(context);
                          setState(() {

                          });
                          await DatabaseHelper().getAllProfile();
                          setState(() {
                          });
                        },

                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_rounded,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Add a Picture",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),


                    // ElevatedButton(
                    //     onPressed: () async {
                    //
                    //       var pList = await DatabaseHelper().getAllProfile();
                    //       setState(() {
                    //       });
                    //       //btnReload
                    //
                    //       print(pList[0].id);
                    //       print(pList[0].name);
                    //       print('Image64Bit = \n'+pList[0].image64bit);
                    //       print('Sql data Type = ${pList.runtimeType} : ${pList.length}\n ${pList[0]}');
                    //       // savedImages.add(File(pList[0].toString()));
                    //       print('Saved Image=  : ${savedImages} : ${savedImages.runtimeType} : ${savedImages.length}');
                    //       // setState(() {});
                    //       getFromUserpic();
                    //       // UserRepo().getUserspic(_database);
                    //     },
                    //     child: Text('Reload')),



                    // ElevatedButton(
                    //     onPressed: () async {
                    //       print('Loveyou : $AssetSelected');
                    //
                    //     },
                    //     child: Text('Check')),
                    //Text(datas[1].picture.toString()),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),

                // child: imageFile != null ? Image.file(imageFile!)
                //  : Container(),
              ),
              // ElevatedButton(
              //     onPressed: () {
              //       print('saveimages$savedImages');
              //       // uploadFile();
              //     },
              //     child: Text('abc')),
              SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 500,
                // width: 200,
                child: StatefulBuilder(builder: (context, setState) {
                  // setState((){
                  //   great;
                  // });
                  return FutureBuilder (
                    future: imageload,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator());
                      }
                      else{
                        var x=snapshot.data;
                        return DragSelectGridView(
                        gridController: controller,
                        itemCount: great.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 8, crossAxisCount: 3, mainAxisSpacing: 8),
                        itemBuilder: (context, index, isSelected) {

                          if (isSelected) {
                            // if (MyimagesList.isNotEmpty &&
                            //     MyimagesList.where((element) => element.index == index)
                            //         .length ==
                            //         0) {
                            //   MyimagesList.add(
                            //       new MyImages(savedImages[index], isSelected, index));
                            // } else if (MyimagesList.isEmpty) {
                            //   MyimagesList.add(
                            //       new MyImages(savedImages[index], isSelected, index));
                            // }
                          } else if (great != null && !isSelected) {
                            // MyimagesList.remove(value);
                          }
                          // savedImages = savedImages;

                          if (isSelected == false) {
                            return Stack(overflow: Overflow.visible, children: [
                              Positioned(
                                child: Image.memory(const Base64Decoder().convert(great[index].image64bit.toString()),height: 150,width: 150,fit: BoxFit.cover,filterQuality: FilterQuality.low),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  left: 90,
                                  child: IconButton(
                                      onPressed: () async{
                                        // Fluttertoast.showToast(msg: 'msg');
                                        print('yes');
                                        // Fluttertoast.showToast(msg: '${great[index].id}');
                                        setState(() {
                                          DatabaseHelper().deleteImage(great[index].id);

                                        });
                                        var pList = await DatabaseHelper().getAllProfile();
                                        setState(() {
                                        });
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red))),
                            ]);
                          }
                          else{
                            return isSelected
                                ? SelectableItemWidget(
                                url: great[index].image64bit, IsSelected: isSelected)
                                : Container();
                            // return Text('data');
                          }
                        });







                        // return DragSelectGridView(
                        //     gridController: controller,
                        //     itemCount: great.length,
                        //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //         crossAxisSpacing: 8, crossAxisCount: 3, mainAxisSpacing: 8),
                        //     itemBuilder: (context, index, isSelected) {
                        //       if (isSelected) {
                        //         if (MyimagesList.isNotEmpty &&
                        //             MyimagesList.where((element) => element.index == index)
                        //                 .length ==
                        //                 0) {
                        //           MyimagesList.add(
                        //               new MyImages(savedImages[index], isSelected, index));
                        //         } else if (MyimagesList.isEmpty) {
                        //           MyimagesList.add(
                        //               new MyImages(savedImages[index], isSelected, index));
                        //         }
                        //       } else if (savedImages != null && !isSelected) {
                        //         // MyimagesList.remove(value);
                        //       }
                        //       savedImages = savedImages;
                        //       if (isSelected == false) {
                        //         return Stack(overflow: Overflow.visible, children: [
                        //           Positioned(
                        //             child: Image.file(
                        //               File(savedImages[index].path).absolute,
                        //               fit: BoxFit.cover,
                        //               width: 150,
                        //               height: 150,
                        //             ),
                        //           ),
                        //           Positioned(
                        //               top: 0,
                        //               right: 0,
                        //               left: 90,
                        //               child: IconButton(
                        //                   onPressed: () {
                        //                     setState(() {
                        //                       savedImages.removeAt(index);
                        //                     });
                        //                   },
                        //                   icon: Icon(Icons.delete, color: Colors.red))),
                        //         ]);
                        //       }
                        //
                        //       return isSelected
                        //           ? SelectableItemWidget(
                        //           url: savedImages[index].path, IsSelected: isSelected)
                        //           : Container();
                        //     });


                        // return ListView.builder(
                        //   itemCount: great.length,
                        //   itemBuilder: (context, index) {
                        //   // return Text(great[index].name);
                        //   return Image.memory(const Base64Decoder().convert(great[index].image64bit.toString()),height: 150,width: 150,);
                        // },);
                      }
                    },);
                },),
                    // buildgrid()
                   // child:  builderGrid(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Visibility(
            visible: isSelect,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
                bottomLeft: Radius.circular(22.0),
                bottomRight: Radius.circular(22.0),
              ),
              child: BottomNavigationBar(
                //elevation: 0.0,

                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.black,

                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.swap_calls),
                    label: 'Swap',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.visibility),
                    label: 'Preview',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.download),
                    label: 'Save',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_outdoor_sharp),
                    label: 'Carousal',
                  ),
                ],
                currentIndex: _selectedIndex,
                fixedColor: Colors.white,
                //selectedItemColor: Colors.blue,
                // selectedLabelStyle: Colors.white,
                unselectedItemColor: Colors.white,

                //  selectedItemColor: Colors.white,

                onTap: (value) async {
                  if (value == 0) {
                    // setState(() {
                    //   File Item0 = savedImages
                    //       .where((element) =>
                    //           element == MyimagesList.first.imageSource)
                    //       .single;
                    //   int Item0Index = savedImages.indexOf(Item0);
                    //   File Item1 = savedImages
                    //       .where((element) =>
                    //           element == MyimagesList.last.imageSource)
                    //       .single;
                    //   int Item1Index = savedImages.indexOf(Item1);
                    //
                    //   var tmp = savedImages[Item0Index];
                    //   savedImages[Item0Index] = savedImages[Item1Index];
                    //   savedImages[Item1Index] = tmp;
                    // });
                    if(AssetSelected.length==2){
                      //btntrue

                      var first=int.parse(AssetSelected[0]);
                      var second=int.parse(AssetSelected[1]);
                      // Fluttertoast.showToast(msg: '${first} = ${first.runtimeType}');
                      setState(() {
                        DatabaseHelper().updateImage(great[first].id, great[second].image64bit);
                        DatabaseHelper().updateImage(great[second].id, great[first].image64bit);
                        great;
                      });
                      var pList = await DatabaseHelper().getAllProfile();
                      setState(() {
                      });

                    }
                    else{
                      Fluttertoast.showToast(msg: 'Swapping require only two photos',backgroundColor: Colors.white,textColor: Colors.black);
                    }
                  };
                  if (value == 1) {
                    setState(() {
                      if (isSelect == true) {
                        var AssetSelected = controller.value.selectedIndexes
                            .map<String>((index) {
                          // var pic=great[index].image64bit.toString();
                          return index.toString();
                        }).toList();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PreviewDart(
                                  urlImages: AssetSelected,
                                )));
                        print('AssetSelectedimages==$AssetSelected');
                      }
                    });
                  }
                  ;

                  if (value == 2) {
                    // var response = dio.download('https://www.google.com/', './xx.html');

                      var AssetSelected =
                          controller.value.selectedIndexes.map<String>((index) {
                        return index.toString();
                      }).toList();
                      var len=AssetSelected.length;
                      if(len==1){
                        var first=int.parse(AssetSelected[0]);
                        var img=great[first].image64bit.toString();
                        var xyz=Base64Decoder().convert(img);
                        var imgg=await DatabaseHelper().downloadImage(xyz);
                        GallerySaver.saveImage(imgg.toString(),
                            albumName: 'instalook')
                            .onError((error, stackTrace) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('$error'),
                        ));})
                            .then((bool) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Image Saved to Gallery'),
                          ));
                          // setState(() {
                          //   print("image saved!");
                          // });
                        });


                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Only 1 photo at a time'),
                              ));
                      }

                      // for(int i=0;i<len;i++){
                        // Fluttertoast.showToast(msg: '${AssetSelected[i]}');
                        // var first=int.parse(AssetSelected[i]);
                        // var img=great[first].image64bit.toString();
                        //
                        // var xyz=Base64Decoder().convert(img);
                        // var imgg=await DatabaseHelper().downloadImage(xyz);
                        // GallerySaver.saveImage(imgg.toString(),
                        //     albumName: 'instalook')
                        // .onError((error, stackTrace) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //   content: Text('$error'),
                        // ));})
                        //     .then((bool) {
                        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //     content: Text('Saved $i'),
                        //   ));
                        //   // setState(() {
                        //   //   print("image saved!");
                        //   // });
                        // });
                      // }


                      // Fluttertoast.showToast(msg: '${imgg}');





                      // GallerySaver.methodSaveImage;

                      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //   content: Text('Save To Gallery : $AssetSelected'),
                      // ));
                  }
                  ;
                  if (value == 3) {
                    setState(() {
                      if (isSelect == true) {
                        var AssetSelected = controller.value.selectedIndexes
                            .map<String>((index) {
                          return index.toString();
                        }).toList();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SaveCaresol(
                                    urlImages: AssetSelected,
                                  )),
                        );
                        print('AssetSelectedimages==$AssetSelected');
                      } else {
                        var AssetSelected = controller.value.selectedIndexes
                            .map<String>((index) {

                          return index.toString();
                        }).toList();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SaveCaresol(
                                  urlImages: AssetSelected,
                                )));
                        print('AssetSelectedimages==$AssetSelected');
                      }
                    });
                  }
                  ;
                },
              ),
            ))
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.black,
        //   onPressed: () {
        //     if (state == AppState.free)
        //       _pickImage();
        //     else if (state == AppState.picked)
        //       _cropImage();
        //     else if (state == AppState.cropped) filter(context);
        //   },
        //   child: _buildButtonIcon(),
        // ),
        );
  }

  Future<String> uploadImage(File image) async {
    print(getImageName(image));
    firebase_storage.Reference db = firebase_storage.FirebaseStorage.instance
        .ref("testFolder/${getImageName(image)}");
    await db.putFile(File(image.path));
    return await db.getDownloadURL();
  }

  String getImageName(File image) {
    return image.path.split("/").last;
  }

  Future<void> _showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Photo Editor'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          imageFile != null
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Container(
                                        height: 270,
                                        child: Image.file(new File(
                                          imageFile!.path,
                                        )),
                                      );
                                    });
                                  },
                                  child: Container(
                                    height: 270,
                                    child: Image.file(new File(
                                      imageFile!.path,
                                    )),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imageFile;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    color: Colors.grey,
                                    child: Center(child: Text('Tap Here')),
                                  ),
                                ),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 45, right: 45),
                                child: Column(
                                  children: [
                                    MaterialButton(
                                      color: Colors.black,
                                      minWidth: double.infinity,
                                      height: 50,
                                      onPressed: ()  {
                                         filter(context);
                                         setState(() {
                                         });
                                      },
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Filter",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    MaterialButton(
                                      color: Colors.black,
                                      minWidth: double.infinity,
                                      height: 50,
                                      onPressed: () async {
                                        _cropImage();
                                      },
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Crop",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 45, right: 45),
                                child: Column(
                                  children: [
                                    MaterialButton(
                                      color: Colors.black,
                                      minWidth: double.infinity,
                                      height: 50,
                                      onPressed: () async {
                                        // Navigator.of(context).pop();
                                        // if (savedImages!=null) {
                                        // }

                                        //btnSave

                                        setState(() {
                                          savedImages.add(imageFile!);
                                          print('avc=$savedImages');
                                        });
                                        if (imageFile != null && imageFile!.path.isNotEmpty) {
                                          setState(() {});
                                          print('Photo Type =${imageFile.runtimeType}');
                                          try{
                                            var x=await encodePhoto(imageFile);
                                            // var y=decodePhoto(x);
                                            // print('Photo Type X =${x.runtimeType}');
                                            // print('Photo Type Y=${x.runtimeType} : ${y}');
                                            await DatabaseHelper.insertProfile(ProfileModel(name: "MyPic", image64bit: x).toMap());
                                            setState(() {
                                            });
                                            var pList = await DatabaseHelper().getAllProfile();
                                            setState(() {
                                            });


                                          }catch(e){
                                            Fluttertoast.showToast(msg: e.toString());
                                          }

                                          // savePicture();
                                          // print(await uploadImage(imageFile!));
                                        }
                                        var pList = await DatabaseHelper().getAllProfile();
                                        setState(() {

                                          great;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MainBottomClass()));
                                          savedImages;
                                        });


                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             FilteredImages()));
                                        // GallerySaver.saveImage(
                                        //         imageFile!.path,
                                        //         albumName: 'instalook')
                                        //     .then((bool) {
                                        //   setState(() {
                                        //     print("image saved!");
                                        //   });
                                        // });

                                        // ScaffoldMessenger.of(context)
                                        //     .showSnackBar(SnackBar(
                                        //   content:
                                        //       Text('Save To Gallery'),
                                        // ));
                                      },
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Save",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  TextEditingController namecontroller = TextEditingController();
  Database? _database;
  Future<Database?> openDB() async {
    _database = await DatabaseHandler().openDB();
    return _database;
  }

  void savePicture() async {
    _database = await openDB();
    UserRepo().createTablepic(_database);
    Picture picture = Picture(picture: imageFile.toString());
    await _database?.insert("MyPic", picture.toMap());
    await _database?.close();
  }


  refreshImages() {
    UserRepo().getpicturess(_database).then((imgs) {
      imagess!.clear();
      imagess!.addAll(imgs);
    });
  }

  Future<void> getFromUserpic() async {
    _database = await openDB();
    // var ab = UserRepo().getUserspic(_database).toString();
    print(await UserRepo().getpicturess(_database));
    var ab = UserRepo().getpicturess(_database);
    datas = await UserRepo().getpicturess(_database);
    print('abc=$datas');

    await _database?.close();
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.filter);
    else
      return Container();
  }

  String? fileName;
  Future<Null> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 50);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
    // if (state == AppState.cropped )
  }
  Future<String> encodePhoto(var image) async{

    var imageBytes = await image!.readAsBytes();
    print("IMAGE PICKED: ${image.path}");

    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
  decodePhoto(var image)  {

    // var imageBytes = await image!.readAsBytes();

    // print("IMAGE PICKED: ${image.path}");

    var decoded = base64Decode(image);
    // var decoded1 = Base64Decoder().convert(image.image64bit.toString());
    // final codec = await instantiateImageCodec(decoded);
    // final frameInfo = await codec.getNextFrame();
    // return frameInfo.image;
    // Uint8List bytes = Base64Codec().decode(image);
    // String base64Image = base64Encode(imageBytes);
    // return decoded1;
  }

  Future<Null> _cropImage() async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  final picker = ImagePicker();
  Future filter(context) async {
    //final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (imageFile != null) {
      imageFile = new File(imageFile!.path);
      fileName = basename(imageFile!.path);
      var image = imageLib.decodeImage(await imageFile!.readAsBytes());
      image = imageLib.copyResize(image!, width: 600);
      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text(" insta look"),
            appBarColor: Colors.black,
            image: image!,
            filters: presetFiltersList,
            filename: fileName!,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );

      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
        });

        print(imageFile!.path);
      }
    }
    setState(() {
      imageFile;
    });
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }

  refreshData() async{

    var pList = await DatabaseHelper().getAllProfile();
    setState(() {
    });
    //btnTest

    print(pList[0].id);
    print(pList[0].name);
    print('Image64Bit = \n'+pList[0].image64bit);
    print('Sql data Type = ${pList.runtimeType} : ${pList.length}\n ${pList[0]}');
    // savedImages.add(File(pList[0].toString()));
    print('Saved Image=  : ${savedImages} : ${savedImages.runtimeType} : ${savedImages.length}');
    // setState(() {});
    getFromUserpic();
    // UserRepo().getUserspic(_database);
  }
  refreshData1(){
    refreshData();
  }
}

class SelectableItemWidget extends StatefulWidget {
  final String url;
  // final VoidCallback onTap;
  final bool IsSelected;
  SelectableItemWidget(
      {Key? key,
      // required this.onTap,
      required this.url,
      required this.IsSelected})
      : super(key: key);

  @override
  State<SelectableItemWidget> createState() => _SelectableItemWidgetState();
}

class _SelectableItemWidgetState extends State<SelectableItemWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(

      // borderRadius: BorderRadius.circular(widget.IsSelected ? 80 : 0),
        child: Container(
            decoration: BoxDecoration(
                border: widget.IsSelected
                    ? Border.all(width: 2, color: Colors.blue)
                    : Border.all(width: 0)),
            // child: Image.file(
            //   File(widget.url).absolute,
            //   fit: BoxFit.cover,
            //   width: 150,
            //   height: 150,
            // ),
            child: Image.memory(Base64Decoder().convert(widget.url),height: 150,width: 150,fit: BoxFit.cover)
          // child: Image.memory(Base64Decoder().convert(widget.url),height: 150,width: 150,fit: BoxFit.cover),
        ));
  }

}

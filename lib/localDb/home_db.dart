import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_look/localDb/database_handler.dart';
import 'package:insta_look/localDb/user_model.dart';
import 'package:insta_look/localDb/user_repo.dart';
import 'package:insta_look/models/crope_n.dart';
import 'package:sqflite/sqflite.dart';

class HomeDB extends StatefulWidget {
  HomeDB({Key? key}) : super(key: key);

  @override
  State<HomeDB> createState() => _HomeDBState();
}

class _HomeDBState extends State<HomeDB> {
  File? imfile;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  Database? _database;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextFormField(
              controller: namecontroller,
              decoration: InputDecoration(hintText: 'name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextFormField(
              controller: emailcontroller,
              decoration: InputDecoration(hintText: 'email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextFormField(
              controller: agecontroller,
              decoration: InputDecoration(hintText: 'age'),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: ((builder) => Bottomsheet()),
                );
              },
              child: Text('Picke Image')),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 180,
            child: imfile == null
                ? Container()
                : Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      clipBehavior: Clip.hardEdge,
                      child: Image.file(
                        File(imfile!.path),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                // insertDB();
                savePicture();
              },
              child: Text('insert')),
          SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                // getFromUser();
                getFromUserpic();
              },
              child: Text('read')),
        ],
      )),
    );
  }

  Widget Bottomsheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Text(
            "Chose profile photo",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton.icon(
                  onPressed: () {
                    getGalleryImage();
                  },
                  icon: Icon(Icons.image),
                  label: Text("Gallery ")),
            ],
          ),
        ],
      ),
    );
  }

  void getGalleryImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 500,
      maxWidth: 500,
    );
    setState(() {
      imfile = File(image!.path);
    });
  }

  Future<Database?> openDB() async {
    _database = await DatabaseHandler().openDB();
    return _database;
  }

  void savePicture() async {
    _database = await openDB();
    UserRepo().createTablepic(_database);
    Picture picture = Picture(picture: imfile.toString());
    await _database?.insert("MyPic", picture.toMap());
    await _database?.close();
  }

  Future<void> getFromUserpic() async {
    _database = await openDB();
    UserRepo().getUserspic(_database);
    await _database?.close();
  }

  Future<void> insertDB() async {
    _database = await openDB();
    UserRepo().createTable(_database);
    UserModel userModel = UserModel(
        namecontroller.text.toString(),
        emailcontroller.text.toString(),
        int.tryParse(agecontroller.text.toString())!);

    await _database?.insert('User', userModel.toMap());

    await _database?.close();
  }

  Future<void> getFromUser() async {
    _database = await openDB();
    UserRepo().getUsers(_database);
    await _database?.close();
  }
}

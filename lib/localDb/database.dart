import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_look/models/profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart' as path;

var great;

class DatabaseHelper {
  static const profileTable = "profiletable";
  static const dbVersion = 1;

  static const idProfileColumn = "id";
  static const nameColumn = "name";
  static const image64bitColumn = "image64bit";

  static Future _onCreate(Database db, int version) {
    return db.execute("""
    CREATE TABLE $profileTable(
    $idProfileColumn INTEGER PRIMARY KEY AUTOINCREMENT,
    $nameColumn TEXT,
    $image64bitColumn TEXT
    
    )    
    """);
  }

  static open() async {
    final rootPath = await getDatabasesPath();

    print("DB OPENED");
    final dbPath = path.join(rootPath, "GosolDb.db");

    return openDatabase(dbPath, onCreate: _onCreate, version: dbVersion);
  }

  static Future insertProfile(Map<String, dynamic> row) async {
    final db = await DatabaseHelper.open();
    print("ROW INSERTED");
    return await db.insert(profileTable, row);
  }

   getAllProfile() async {
    final db = await DatabaseHelper.open();

    List<Map<String, dynamic>> mapList = await db.query(profileTable);

    great= List.generate(
        mapList.length, (index) => ProfileModel.fromMap(mapList[index]));
  return great;
  }
  deleteImage(var id) async {
    final db = await DatabaseHelper.open();
    return db.execute("DELETE FROM $profileTable WHERE $idProfileColumn=$id");
  }
  updateImage(int id,String image) async {
    final db = await DatabaseHelper.open();
    var count = await db.rawUpdate( 'UPDATE $profileTable SET $image64bitColumn = ? WHERE $idProfileColumn = ?', [image, id]);
    return count;
  }
  downloadImage(Uint8List img) async {
    final appstorage=await getApplicationDocumentsDirectory();
    final file=File('${appstorage.path}/image.png');
    await file.writeAsBytes(img);
    return file.path;
    // await Dio().download(file.path, savePath)
  }

}

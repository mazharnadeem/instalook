import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:insta_look/localDb/user_model.dart';
import 'package:sqflite/sqlite_api.dart';

class UserRepo {
  void createTable(Database? db) {
    db?.execute(
        'CREATE TABLE IF NOT EXISTS USER(id INTEGER PRIMARY KEY, name TEXT,email TEXT, age INTEGER)');
  }

  void createTablepic(Database? db) {
    db?.execute(
        "CREATE TABLE MyPic(id INTEGER PRIMARY KEY, title TEXT, picture BLOB )");
  }

  Database? _database;
  Future<void> getUserspic(Database? db) async {
    final List<Map<String, dynamic>> maps = await db!.query('MyPic');
    print('maps==$maps');
  }

  Future<List<Picture>> getpicturess(Database? db) async {
    final List<Map<String, dynamic>> maps = await db!.query('MyPic');
    // final result = await db.rawQuery('SELECT * FROM Mypic ORDER BY ASC');

    return maps.map((e) => Picture.fromMap(e)).toList();
  }

  Future<void> getUsers(Database? db) async {
    final List<Map<String, dynamic>> maps = await db!.query('User');

    print(maps);
  }
}

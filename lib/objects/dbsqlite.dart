import 'dart:async';

import 'package:flutter/cupertino.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbSqlite {
  Database _db;
  DatabaseFactory databaseFactory;
  String path;
  String tableName = "files";
  String fileColumnName = "fileName";
  int _databaseVersion = 1;

  //DbSqlite({path = ""});
  DbSqlite() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  initDb() async {
    /*openDatabase(
      inMemoryDatabasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );*/

    var options =
        OpenDatabaseOptions(onCreate: _onCreate, version: _databaseVersion);

    this._db = await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: options);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableName (
            $fileColumnName TEXT PRIMARY KEY
          )
          ''');
  }

  Future<int> insert(String path) async {
    //Database db = await instance.database;
    //var res = await _database.insert("filesystem", );
    //_db.insert(tableName, values)
    //print(path);
    //print(this._db);

    if (_db != null) {
      await _db.insert(
        tableName,
        <String, Object>{fileColumnName: path},
      );
    }
    /*_db.execute(
        "INSERT INTO $fileColumnName ($fileColumnName) VALUES ('$path')");
    //return res;
    return null;*/
  }
}

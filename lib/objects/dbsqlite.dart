import 'dart:async';

import 'package:flutter/cupertino.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:video_convert/objects/fileEntry.dart';

class DbSqlite {
  Database _db;
  DatabaseFactory databaseFactory;
  String path;
  String tableName = "files";
  String fileColumnName = "fileName";
  String fileColumnCreateDatetime = "createDatetime";
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

    print("DbSqlite::initDb() - finished creating the _db");
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableName (
            $fileColumnName TEXT PRIMARY KEY,
            $fileColumnCreateDatetime TEXT NOT NULL
          )
          ''');
  }

  Future<List<String>> getUniqueDatesCreated() async {
    String sql =
        //"SELECT DISTINCT $fileColumnName, substr($fileColumnCreateDatetime, 0, 8) AS $fileColumnCreateDatetime FROM $tableName";
        "SELECT DISTINCT substr($fileColumnCreateDatetime, 0, 8) AS $fileColumnCreateDatetime FROM $tableName ORDER BY $fileColumnCreateDatetime ASC";
    print(sql);

    List<Map> values = [];
    List<String> uniqueDates = [];

    if (this._db != null) {
      values = await _db.rawQuery(sql);

      for (var value in values) {
        uniqueDates.add(value[fileColumnCreateDatetime]);
      }
    } else {
      print("DbSqlite::getUniqueDatesCreated() - _db is null");
    }

    //print("uniqueDates: $uniqueDates");

    return uniqueDates;
  }

  Future<List<FileEntry>> groupFilesByDateCreated(String date) async {
    String sql =
        "SELECT * FROM $tableName WHERE $fileColumnCreateDatetime like '$date%'";
    print(sql);

    List<Map> values = [];
    List<FileEntry> entries = [];

    if (this._db != null) {
      values = await _db.rawQuery(sql);

      for (var value in values) {
        var entry = FileEntry(
            path: value[fileColumnName],
            createDate: value[fileColumnCreateDatetime]);

        entries.add(entry);
      }
    } else {
      print("DbSqlite::groupFilesByDateCreated() - _db is null");
    }

    return entries;
  }

  Future<void> insert(String path, DateTime createDateTime) async {
    //Database db = await instance.database;
    //var res = await _database.insert("filesystem", );
    //_db.insert(tableName, values)
    //print(path);
    //print(this._db);

    try {
      if (this._db != null) {
        await _db.insert(
          tableName,
          <String, Object>{
            fileColumnName: path,
            fileColumnCreateDatetime: createDateTime.toString(),
          },
        );
      } else {
        print("DbSqlite::insert() - this._db is null");
      }
    } catch (exception) {
      print(exception.toString());
    }
    /*_db.execute(
        "INSERT INTO $fileColumnName ($fileColumnName) VALUES ('$path')");
    //return res;
    return null;*/
  }
}

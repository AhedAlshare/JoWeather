import 'dart:io';
import 'package:jo_weather/models/city.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final String table = "JoWeather";
  final String columnId = "id";
  final String columnName = "cityname";
  final String columnTemperature = "temperature";
  final String columnDescription = "description";
  final String columnIcon = "icon";

  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    var join2 = join;
    String path = join2(documentDirectory.path, "maindb.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $table($columnId INTEGER PRIMARY KEY, $columnName TEXT, $columnTemperature TEXT,$columnDescription TEXT,$columnIcon TEXT)");
  }

  Future<int> saveCityW(City city) async {
    var dbClient = await db;
    int result = await dbClient.insert(table, city.toMap());
    print('Saved');
    return result;
  }

  Future<List> getAllCitys() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $table");
    return result.toList();
  }

  Future<City?> getCity(int cityId) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery("SELECT * FROM $table WHERE $columnId = $cityId");
    if (result.length == 0) return null;
    return new City.fromMap(result.first);
  }

  Future<int> deleteCity(int cityId) async {
    var dbClient = await db;
    return await dbClient
        .delete(table, where: "$columnId = ?", whereArgs: [cityId]);
  }

  Future<int> updateCity(City city) async {
    var dbClient = await db;
    print('Updated');

    return await dbClient.update(table, city.toMap(),
        where: "$columnId = ? ", whereArgs: [city.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future<String> getDatabasesPath() => databaseFactory.getDatabasesPath();

  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);
}

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:jo_weather/models/city.dart';
import 'package:jo_weather/models/models.dart';

import '../controller/data_service.dart';
import '../controller/database_helper.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final _dataService = DataService();
  WeatherResponse? _response;

  var db = new DatabaseHelper();
   late City city = City(cityname:"Irbid",description: "",icon:"" );
  String dropdownvalue = 'Irbid';
  var cities = [
    'Irbid',
    'Mafraq',
    'Jerash',
    'Ajloun',
    'Balqa',
    'Amman',
    'Zarqa',
    'Tafilah',
    'Karak',
    'Madaba',
    'Maan',
    'Aqaba',
  ];

  @override
  void initState() {
    _search();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.blue[100],
      body: EasyRefresh(
        onRefresh: () async {
          await updateInfo();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_response != null && city.temperature != null) 
              Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Column(
                  children: [
                    Image.network(_response!.iconUrl),
                    Text(
                      "${_convertF2c(num.parse(city.temperature!))} C°",
                      style: TextStyle(fontSize: 40),
                    ),
                    Text(
                      "${city.temperature!} F°",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(city.description!),

                  
                     
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: 140,
                child: Row(
                  children: [
                    Text("  City :  "),
                    DropdownButton(
                      value: dropdownvalue,
                      icon: Icon(Icons.keyboard_arrow_down),
                      items: cities.map((String items) {
                        return DropdownMenuItem(
                            value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                        });
                        _search();
                      },
                    ),
                  ],
                ),
              ),
            ),
             Text("Swipe down to Refresh ▼ "),
          ],
        ),
      ),
    );
  }

  void _search() async {
    int indexId = cities.indexOf(dropdownvalue) + 1;
    bool dbExit = await db.databaseExists(await db.getDatabasesPath());
    if (!dbExit) {
      check().then((internet) async {
        if (internet) {
          await _dataService.getWeather(dropdownvalue).then((value) {
            _response = value;
          });
          City? cityIsExit = await db.getCity(indexId);
          if (cityIsExit == null)
            await db.saveCityW(City(
                id: indexId,
                cityname: dropdownvalue,
                temperature: _response!.tempInfo.temperature.toString(),
                description: _response!.weatherInfo.description,
                icon: _response!.weatherInfo.icon));
          else
            city = (await db.getCity(indexId))!;
          setState(() {});
        } else
          city = (await db.getCity(indexId))!;
        setState(() {});
      });
    }
  }

  updateInfo() async {
    int indexId = cities.indexOf(dropdownvalue) + 1;

    await _dataService.getWeather(dropdownvalue).then((value) {
      _response = value;
    });
    db.updateCity(City(
        id: indexId,
        cityname: dropdownvalue,
        temperature: _response!.tempInfo.temperature.toString(),
        description: _response!.weatherInfo.description,
        icon: _response!.weatherInfo.icon));
    city = (await db.getCity(indexId))!;
    setState(() {});
  }

  int _convertF2c(num degreeF) {
    double degreeC = ((degreeF - 32) * 5) / 9;
    return degreeC.toInt();
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}

class City {
  String? cityname;
  String? temperature;
  String? description;
  String? icon;
  int? id;

  City({this.id, this.cityname, this.temperature, this.description,
      this.icon});

  City.map(dynamic obj) {
    this.id = obj['id'];
    this.cityname = obj['cityname'];
    this.temperature = obj['temperature'];
    this.description = obj['description'];
    this.icon = obj['icon'];
  }

  //getters
  // int get id => id!;
  // String? get cityname => cityname;
  // String? get temperature => temperature;
  // String? get description => description;
  // String? get icon => icon;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["cityname"] = cityname;
    map["temperature"] = temperature;
    map["description"] = description;
    map["icon"] = icon;

    return map;
  }

  City.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.cityname = map["cityname"];
    this.temperature = map["temperature"];
    this.description = map["description"];
    this.icon = map["icon"];
  }
}

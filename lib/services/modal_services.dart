List<District> districts = [];
List<Region> regions = [];

class Region {
  var id;
  String name;
  double lat, long;
  Region(this.id, this.name, this.lat, this.long);
}

class District {
  var id, name;
  District(this.id, this.name);
}

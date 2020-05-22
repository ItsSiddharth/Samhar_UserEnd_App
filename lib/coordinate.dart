class Coordinate {

  final double latitude;
  final double longitude;
  final String datetime;
  final String email;

  Coordinate({
    this.latitude,
    this.longitude,
    this.datetime,
    this.email
  });

  factory	Coordinate.fromJson(Map<dynamic, dynamic> json) {
    return Coordinate(
      latitude: 0,
      longitude: 0,
      datetime: DateTime.now().toString(),
    );
  }

  Map<String, dynamic>toJson(){
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'datetime': datetime
    };
  }
}
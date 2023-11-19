import 'dart:convert';

import 'package:http/http.dart' as http;

//Using open meteo api
Future<Map<String, dynamic>> getWeatherInfo(String stationName, String lon, String lat) async {
  var request = http.Request(
      'GET',
      Uri.parse(
          'https://api.open-meteo.com/v1/forecast?longitude=$lon&latitude=$lat&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=Asia%2FSingapore'));
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    var current = jsonDecode(await response.stream.bytesToString())["current"];
    var times = current["time"].toString().replaceAll("-", "/").split("T");
    Map<String, dynamic> result = {
      "SourceType": 0,
      "StationID": "$lon,$lat",
      "LocationName": stationName,
      "obsTime": "${times[0]} ${times[1].substring(0, 5)}",
    };
    for (var key in current.keys) {
      if (key != "time" && key != "interval") {
        result[key] = current[key];
      }
    }
    return result;
  } else {
    return {"Error": "Error:${response.reasonPhrase}"};
  }
}

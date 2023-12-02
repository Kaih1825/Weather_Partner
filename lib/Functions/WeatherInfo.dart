import 'dart:convert';

import 'package:http/http.dart' as http;

//Using open meteo api
Future<Map<String, dynamic>> getWeatherInfo(String stationName, String lon, String lat) async {
  try {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.open-meteo.com/v1/forecast?longitude=$lon&latitude=$lat&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=Asia%2FSingapore&hourly=uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_hours,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var getResult = jsonDecode(await response.stream.bytesToString());
      var current = getResult["current"];
      var hourly = getResult["hourly"];
      var daily = getResult["daily"];
      var times = current["time"].toString().replaceAll("-", "/").split("T");
      Map<String, dynamic> result = {
        "SourceType": 0,
        "StationID": "$lon,$lat",
        "LocationName": stationName,
        "obsTime": "${times[0]} ${times[1].substring(0, 5)}",
      };
      var currentResult = {};
      var hourlyResult = {};
      var dailyResult = {};
      for (var key in current.keys) {
        if (key != "time" && key != "interval") {
          currentResult[key] = current[key];
        }
      }
      for (var key in hourly.keys) {
        hourlyResult[key] = hourly[key];
      }
      for (var key in daily.keys) {
        dailyResult[key] = daily[key];
      }
      result["CurrentWeather"] = currentResult;
      result["HourlyWeather"] = hourlyResult;
      result["DailyWeather"] = dailyResult;
      return result;
    } else {
      return {"Error": "Error:${response.reasonPhrase}"};
    }
  } catch (e) {
    return {"Error": "Error:$e"};
  }
}

Future<Map<String, dynamic>> getWeatherPartner(String stationName, String stationId) async {
  var request = http.Request('GET', Uri.parse('http://202.5.226.152/data/$stationId'));

  http.StreamedResponse response = await request.send();

  if (response.statusCode != 200) {
    return {"Error": "Error:${response.reasonPhrase}"};
  }
  var result = jsonDecode(await response.stream.bytesToString())["data"][0];
  result["SourceType"] = 1;
  result["StationID"] = stationId;
  result["LocationName"] = stationName;
  return result;
}

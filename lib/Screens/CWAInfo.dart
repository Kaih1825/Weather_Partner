import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../ApiKeys/ApiKeys.dart';
import '../Widgets/Block.dart';
import 'package:http/http.dart' as http;

class CWAInfo extends StatefulWidget {
  final Map tiWeatherInfo;
  final bool isNight;
  final Widget refreshWidget;
  const CWAInfo({super.key, required this.tiWeatherInfo, required this.isNight, required this.refreshWidget});

  @override
  State<CWAInfo> createState() => _CWAInfoState();
}

class _CWAInfoState extends State<CWAInfo> {
  
  get tisWeatherInfo => widget.tiWeatherInfo;
  get _isNight => widget.isNight;
  late var uvi = double.parse(tisWeatherInfo["H_UVI"]).round();
  var uviString = "";
  var uviColor = Colors.white;

  void _getWeatherInfo(String stationID, String placeType) async {
    try {
      var response = await http.get(
        Uri.https('opendata.cwa.gov.tw', 'api/v1/rest/datastore/O-A0003-001',
            {"Authorization": cwaKeys, "stationId": stationID}),
      );
      var location = jsonDecode(response.body)["records"]["location"][0];
      var weatherElement = location["weatherElement"];
      var weatherMap = {};
      weatherMap["obsTime"] = location["time"]["obsTime"];
      weatherMap["locationName"] = location["locationName"];
      weatherMap["city"] = location["parameter"][0]["parameterValue"];
      weatherMap["district"] = location["parameter"][2]["parameterValue"];
      for (var tisElement in weatherElement) {
        weatherMap[tisElement["elementName"]] = tisElement["elementValue"];
      }
      var box = Hive.box("RecentWeather");
      await box.put(stationID, weatherMap);
      await box.put("PlaceInfo", {"SourceType": placeType, "StationID": stationID});
    } catch (ex) {
      print(ex);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (uvi < 3) {
      uviString = "低量級";
      uviColor = const Color(0xff289500);
    } else if (uvi < 6) {
      uviString = "中量級";
      uviColor = const Color(0xffF7e400);
    } else if (uvi < 8) {
      uviString = "高量級";
      uviColor = const Color(0xffF85900);
    } else if (uvi < 11) {
      uviString = "過量級";
      uviColor = const Color(0xffd8001d);
    } else {
      uviString = "危險級";
      uviColor = const Color(0xff6B49C8);
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    child: Column(
                      children: [
                        Text(
                          "${tisWeatherInfo["city"]} ${tisWeatherInfo["district"]}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          strutStyle: const StrutStyle(
                            forceStrutHeight: true,
                            leading: 0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "${tisWeatherInfo["locationName"]}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            strutStyle: const StrutStyle(
                              forceStrutHeight: true,
                              leading: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _isNight ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "觀測時間",
                            style: TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            tisWeatherInfo["obsTime"]
                                .toString()
                                .replaceAll("-", "/")
                                .substring(0, tisWeatherInfo["obsTime"].toString().length - 3),
                            style: const TextStyle(color: Colors.white),
                          ),
                         widget.refreshWidget,
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        Block(
                          isnight: _isNight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.device_thermostat,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Symbols.humidity_mid,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              Text(
                                "${tisWeatherInfo["Weather"]}",
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              Text(
                                "${tisWeatherInfo["TEMP"]}˚",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                "${(double.parse(tisWeatherInfo["HUMD"]) * 100).round()}%",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Block(
                          isnight: _isNight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Symbols.air,
                                color: Colors.white,
                                size: 25,
                              ),
                              Transform.rotate(
                                angle: 2 *
                                    pi *
                                    double.parse(tisWeatherInfo["WDIR"].toString() == "990"
                                        ? tisWeatherInfo["H_XD"]
                                        : tisWeatherInfo["WDIR"]) /
                                    360,
                                child: const Icon(
                                  Symbols.navigation,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              Text(
                                "${tisWeatherInfo["WDIR"].toString() == "990" ? tisWeatherInfo["H_XD"] : tisWeatherInfo["WDIR"]}˚",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                "${tisWeatherInfo["WDSD"]}m/s",
                                // "${tisWeatherInfo["WDSD"]}ᵐ/ₛ",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        if ("${tisWeatherInfo["H_UVI"]}" != "-99")
                          Block(
                            isnight: _isNight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Spacer(),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(360),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            Symbols.sunny,
                                            color: uviColor,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        " UV",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    "${tisWeatherInfo["H_UVI"]}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    uviString,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer()
                                ],
                              ),
                            ),
                          ),
                        Block(
                          isnight: _isNight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Symbols.air,
                                color: Colors.white,
                                size: 25,
                              ),
                              Transform.rotate(
                                angle: 2 *
                                    pi *
                                    double.parse(tisWeatherInfo["WDIR"].toString() == "990"
                                        ? tisWeatherInfo["H_XD"]
                                        : tisWeatherInfo["WDIR"]) /
                                    360,
                                child: const Icon(
                                  Symbols.navigation,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              Text(
                                "${tisWeatherInfo["WDIR"].toString() == "990" ? tisWeatherInfo["H_XD"] : tisWeatherInfo["WDIR"]}˚",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                "${tisWeatherInfo["WDSD"]}m/s",
                                // "${tisWeatherInfo["WDSD"]}ᵐ/ₛ",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

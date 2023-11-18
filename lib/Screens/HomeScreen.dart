import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'package:weather_partner/Screens/CWAInfo.dart';
import 'package:weather_partner/Utils/GetColor.dart';

import '../ApiKeys/ApiKeys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  var _sourceType = 0;
  final _fabPageController = PageController();
  late final _fabAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final _fabTween =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fabAnimation, curve: Curves.easeInOut));
  late final _refreshAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  late final _refreshTween = Tween(begin: 0.0, end: 2 * pi * 90 / 360).animate(_refreshAnimation);
  var _placeInfo = {};
  var _isNight = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fabAnimation.addListener(() {
      setState(() {});
    });
    _refreshAnimation.addListener(() {
      setState(() {});
    });
    _refreshAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _refreshAnimation.reverse();
      }
    });
    var recent = Hive.box("RecentWeather");
    _placeInfo = recent.get("PlaceInfo") ?? {};
    recent.watch().listen((event) {
      try {
        if (event.value["StationID"] != null) {
          _placeInfo = {"SourceType": event.value["SourceType"], "StationID": event.value["StationID"]};
          _isNight = Hive.box("RecentWeather").get(_placeInfo["StationID"]) != null
              ? int.parse(Hive.box("RecentWeather")
                          .get(_placeInfo["StationID"])["obsTime"]
                          .toString()
                          .split(" ")[1]
                          .split(":")[0]) >=
                      18 ||
                  int.parse(Hive.box("RecentWeather")
                          .get(_placeInfo["StationID"])["obsTime"]
                          .toString()
                          .split(" ")[1]
                          .split(":")[0]) <=
                      6
              : false;
          setState(() {});
        }
      } catch (ex) {}
    });
    _isNight = Hive.box("RecentWeather").get(_placeInfo["StationID"]) != null
        ? int.parse(Hive.box("RecentWeather")
                    .get(_placeInfo["StationID"])["obsTime"]
                    .toString()
                    .split(" ")[1]
                    .split(":")[0]) >=
                18 ||
            int.parse(Hive.box("RecentWeather")
                    .get(_placeInfo["StationID"])["obsTime"]
                    .toString()
                    .split(" ")[1]
                    .split(":")[0]) <=
                6
        : false;
    if (_placeInfo.isNotEmpty) {
      _getWeatherInfo(_placeInfo["StationID"], _placeInfo["SourceType"].toString());
    }
    Timer.periodic(const Duration(minutes: 15), (timer) {
      print("Time");
      if (_placeInfo.isNotEmpty) {
        print("Update");
        _getWeatherInfo(_placeInfo["StationID"].toString(), _placeInfo["SourceType"].toString());
      }
    });
    setState(() {});
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _fab(),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              _isNight ? "assets/day_night.png" : "assets/day_light.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: const Color(0xff071526).withOpacity(_isNight ? 0.65 : 0.0),
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.only(
                top: kIsWeb
                    ? 10
                    : Platform.isMacOS || Platform.isWindows || Platform.isLinux
                        ? 20
                        : 10),
            child: ValueListenableBuilder(
              valueListenable: Hive.box("RecentWeather").listenable(),
              builder: (BuildContext context, Box<dynamic> box, Widget? child) {
                var tisWeatherInfo = box.get(_placeInfo["StationID"]);
                if (tisWeatherInfo != null) {
                  if (int.parse(_placeInfo["SourceType"].toString()) == 0) {
                    if (tisWeatherInfo["city"] != null && _placeInfo["StationID"] != null) {
                      _isNight = Hive.box("RecentWeather").get(_placeInfo["StationID"]) != null
                          ? int.parse(Hive.box("RecentWeather")
                          .get(_placeInfo["StationID"])["obsTime"]
                          .toString()
                          .split(" ")[1]
                          .split(":")[0]) >=
                          18 ||
                          int.parse(Hive.box("RecentWeather")
                              .get(_placeInfo["StationID"])["obsTime"]
                              .toString()
                              .split(" ")[1]
                              .split(":")[0]) <=
                              6
                          : false;
                      return CWAInfo(
                        tiWeatherInfo: tisWeatherInfo,
                        isNight: _isNight,
                        refreshWidget:  Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            child: Transform.rotate(
                              angle: _refreshTween.value,
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              var box = Hive.box("RecentWeather");
                              var info = box.get("PlaceInfo");
                              _getWeatherInfo(
                                  info["StationID"].toString(), info["SourceType"].toString());
                              _refreshAnimation.forward();
                            },
                          ),
                        ),
                      );
                    }
                  }
                }
                // }
                return const Text("無資料");
              },
            ),
          ),
          if (_fabTween.value != 0)
            GestureDetector(
              onTap: () {
                _fabAnimation.reverse();
              },
              child: Container(
                color: Colors.black.withOpacity(_fabTween.value * 0.5),
              ),
            )
        ],
      ),
    );
  }

  Widget _fab() {
    return Container(
      height: 70 + _fabTween.value * MediaQuery.of(context).size.height / 2,
      width: 70 + _fabTween.value * MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 + 10 * _fabTween.value),
          color: _isNight
              ? GetColor.getOnSecondaryDark(Theme.of(context))
              : Theme.of(context).colorScheme.secondaryContainer,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isNight ? 0 : 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(5, 5),
            ),
          ]),
      child: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 1 - _fabTween.value,
              child: Visibility(
                visible: _fabTween.value != 1,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20 + 30 * _fabTween.value),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent.withOpacity(0.1),
                    ),
                    onPressed: () {
                      if (_fabAnimation.status != AnimationStatus.completed) {
                        _fabAnimation.forward();
                      }
                    },
                    child: Icon(
                      Icons.menu,
                      color: _isNight
                          ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Opacity(
              opacity: _fabTween.value,
              child: Visibility(
                  visible: _fabTween.value == 1,
                  child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 18,
                        color: _isNight ? GetColor.getOnSecondaryContainerDark(Theme.of(context)) : Colors.black),
                    child: PageView(
                      controller: _fabPageController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "資料來源：",
                                style: TextStyle(
                                    color: _isNight
                                        ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                        : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _sourceType = 0;
                                      _fabPageController.animateToPage(1,
                                          duration: const Duration(milliseconds: 200), curve: Curves.linear);
                                      setState(() {});
                                    },
                                    child: Card(
                                      color: _isNight
                                          ? GetColor.getSecondaryContainerDark(Theme.of(context))
                                          : Theme.of(context).colorScheme.surface,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/roc_cwa.png",
                                              width: 25,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                "中央氣象署CWA",
                                                style: TextStyle(
                                                    color: _isNight
                                                        ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                                        : Theme.of(context).colorScheme.onSurface),
                                              ),
                                            ),
                                            Spacer(),
                                            const Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              color: Colors.grey,
                                              size: 13,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _fabPageController.animateToPage(0,
                                        duration: const Duration(milliseconds: 200), curve: Curves.linear);
                                  },
                                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () async {
                                    var res = await context
                                        .pushNamed("/ap", queryParameters: {"Type": _sourceType.toString()});
                                    if (res == 0) {
                                      _fabAnimation.reverse();
                                    }
                                  },
                                  child: Text("新增地點"),
                                )
                              ],
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box("Places").listenable(),
                                builder: (BuildContext context, Box<dynamic> value, Widget? child) {
                                  var allPlace = value.values
                                      .toList()
                                      .where((element) => element["SourceType"] == _sourceType)
                                      .toList();
                                  _isNight = Hive.box("RecentWeather").get(_placeInfo["StationID"]) != null
                                      ? int.parse(Hive.box("RecentWeather")
                                                  .get(_placeInfo["StationID"])["obsTime"]
                                                  .toString()
                                                  .split(" ")[1]
                                                  .split(":")[0]) >=
                                              18 ||
                                          int.parse(Hive.box("RecentWeather")
                                                  .get(_placeInfo["StationID"])["obsTime"]
                                                  .toString()
                                                  .split(" ")[1]
                                                  .split(":")[0]) <=
                                              6
                                      : false;
                                  return ListView.builder(
                                    itemCount: allPlace.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () async {
                                          var box = Hive.box("RecentWeather");
                                          await box.put("PlaceInfo", {
                                            "SourceType": allPlace[index]["SourceType"],
                                            "StationID": allPlace[index]["StationID"]
                                          });
                                          _placeInfo = {
                                            "SourceType": allPlace[index]["SourceType"],
                                            "StationID": allPlace[index]["StationID"]
                                          };
                                          _getWeatherInfo(allPlace[index]["StationID"].toString(),
                                              allPlace[index]["SourceType"].toString());
                                          _fabAnimation.reverse();
                                        },
                                        child: Card(
                                          color: _isNight
                                              ? GetColor.getSecondaryContainerDark(Theme.of(context))
                                              : Theme.of(context).colorScheme.surface,
                                          child: ListTile(
                                            title: Text(
                                              allPlace[index]["LocationName"].toString(),
                                              style: TextStyle(
                                                  color: _isNight
                                                      ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                                      : Theme.of(context).colorScheme.onSurface),
                                            ),
                                            subtitle: Text(
                                              allPlace[index]["StationName"].toString(),
                                              style: TextStyle(
                                                  color: _isNight
                                                      ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                                      : Theme.of(context).colorScheme.onSurface),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }

}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:weather_partner/Functions/WeatherInfo.dart';
import 'package:weather_partner/Utils/GetColor.dart';
import 'package:weather_partner/Widgets/OpenMeteoWeatherInfo.dart';
import 'package:weather_partner/Widgets/WeatherPartnerWeatherInfo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  var _sourceType = 0;
  final _fabPageController = PageController();
  late final _fabAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  late final _fabTween = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fabAnimation, curve: Curves.easeInOut));
  var _placeInfo = {};
  var _isNight = false;
  var _timer = Timer(const Duration(seconds: 1), () {});

  @override
  void dispose() {
    _fabAnimation.dispose();
    _fabPageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fabAnimation.addListener(() {
      setState(() {});
    });

    var recent = Hive.box("RecentWeather");
    if (recent.isEmpty) {
      handleNoPlaces(1);
    } else {
      handleNoPlaces(0);
    }
    getWeatherInInit();

    recent.watch().listen((event) {
      try {
        if (event.value["StationID"] != null) {
          _placeInfo = {"SourceType": event.value["SourceType"], "StationID": event.value["StationID"], "LocationName": event.value["LocationName"]};
          if (event.value["SourceType"] == 0 && event.value["CurrentWeather"]["is_day"] != null) {
            _isNight = event.value["CurrentWeather"]["is_day"] == 0 ? true : false;
          }
          if (event.value["SourceType"] == 1) {
            _isNight = (int.parse(event.value["time"].split(" ")[1].split(":")[0].toString()) < 6 && event.value["time"].split(" ")[2] == "AM") ||
                (int.parse(event.value["time"].split(" ")[1].split(":")[0].toString()) > 6 && event.value["time"].split(" ")[2] == "PM");
          }
          setState(() {});
        }
        // ignore: empty_catches
      } catch (ex) {}
    });

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_placeInfo.isNotEmpty) {
        if (_placeInfo["SourceType"] == 0) {
          var lonlat = _placeInfo["StationID"].toString().split(",");
          var weatherInfo = await getWeatherInfo(_placeInfo["LocationName"], lonlat[0], lonlat[1]);
          await recent.put(_placeInfo["StationID"], weatherInfo);
          _placeInfo = weatherInfo;
          if (_placeInfo["CurrentWeather"]["is_day"] != null) {
            _isNight = _placeInfo["CurrentWeather"]["is_day"] == 0 ? true : false;
          }
        }
        if (_placeInfo["SourceType"] == 1) {
          var weatherInfo = await getWeatherPartner(_placeInfo["LocationName"], _placeInfo["StationID"]);
          if (weatherInfo["Error"] == null) {
            await recent.put(_placeInfo["StationID"], weatherInfo);
            _placeInfo = weatherInfo;
            _isNight = (int.parse(weatherInfo["time"].split(" ")[1].split(":")[0].toString()) < 6 && weatherInfo["time"].split(" ")[2] == "AM") ||
                (int.parse(weatherInfo["time"].split(" ")[1].split(":")[0].toString()) > 6 && weatherInfo["time"].split(" ")[2] == "PM");
          }
        }
        setState(() {});
      }
    });

    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  void getWeatherInInit() async {
    var recent = Hive.box("RecentWeather");
    _placeInfo = recent.get("PlaceInfo") ?? {};
    if (_placeInfo.isNotEmpty) {
      if (_placeInfo["SourceType"] == 0) {
        var lonlat = _placeInfo["StationID"].toString().split(",");
        var weatherInfo = await getWeatherInfo(_placeInfo["LocationName"], lonlat[0], lonlat[1]);
        if (weatherInfo["Error"] == null) {
          await recent.put(_placeInfo["StationID"], weatherInfo);
          _placeInfo = weatherInfo;
          if (_placeInfo["CurrentWeather"]["is_day"] != null) {
            _isNight = _placeInfo["CurrentWeather"]["is_day"] == 0 ? true : false;
          }
        }
      }
      if (_placeInfo["SourceType"] == 1) {
        var weatherInfo = await getWeatherPartner(_placeInfo["LocationName"], _placeInfo["StationID"]);
        if (weatherInfo["Error"] == null) {
          await recent.put(_placeInfo["StationID"], weatherInfo);
          _placeInfo = weatherInfo;
          _isNight = (int.parse(weatherInfo["time"].split(" ")[1].split(":")[0].toString()) < 6 && weatherInfo["time"].split(" ")[2] == "AM") ||
              (int.parse(weatherInfo["time"].split(" ")[1].split(":")[0].toString()) > 6 && weatherInfo["time"].split(" ")[2] == "PM");
        }
      }
    }
  }

  void handleNoPlaces(int type) async {
    var request = http.Request('GET', Uri.parse('https://freeipapi.com/api/json/'));

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = jsonDecode(await response.stream.bytesToString());
      var stationID = "${result["longitude"]},${result["latitude"]}";
      var locationName = "IP所在地 ${result["cityName"]}";
      var box = Hive.box("Places");
      var storageMap = {
        "SourceType": 0,
        "StationID": stationID,
        "LocationName": locationName,
      };
      if (box.isEmpty) {
        await box.add(storageMap);
      } else {
        var key = box.keys
            .map((e) {
              var tisElement = box.get(e);
              return {
                "Key": e,
                "StationID": tisElement["StationID"],
              };
            })
            .toList()
            .where((element) => element["StationID"] == stationID)
            .toList();
        await box.put(key[0]["Key"], storageMap);
      }

      if (type == 1) {
        var weatherInfo = await getWeatherInfo(locationName, result["longitude"].toString(), result["latitude"].toString());
        var weatherBox = Hive.box("RecentWeather");
        await weatherBox.put(stationID, weatherInfo);
        await weatherBox.put("PlaceInfo", {
          "SourceType": 0,
          "StationID": stationID,
          "LocationName": locationName,
        });
        _placeInfo = weatherInfo;
        _isNight = _placeInfo["CurrentWeather"]["is_day"] == 0 ? true : false;
      }
    } else {}
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
                  _placeInfo = tisWeatherInfo;
                  if (tisWeatherInfo["SourceType"] == 0) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: OpenMeteoWeatherInfo(
                          info: tisWeatherInfo,
                          isNight: _isNight,
                        ),
                      ),
                    );
                  }
                  if (tisWeatherInfo["SourceType"] == 1) {
                    return SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: WeatherPartnerWeatherInfo(
                            info: tisWeatherInfo,
                            isNight: _isNight,
                          )),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
          color: _isNight ? GetColor.getOnSecondaryDark(Theme.of(context)) : Theme.of(context).colorScheme.secondaryContainer,
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
                      color: _isNight ? GetColor.getOnSecondaryContainerDark(Theme.of(context)) : Theme.of(context).colorScheme.onSecondaryContainer,
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
                    style: TextStyle(fontSize: 18, color: _isNight ? GetColor.getOnSecondaryContainerDark(Theme.of(context)) : Colors.black),
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
                                    color:
                                        _isNight ? GetColor.getOnSecondaryContainerDark(Theme.of(context)) : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _sourceType = 0;
                                      _fabPageController.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                                      setState(() {});
                                    },
                                    child: Card(
                                      color: _isNight ? GetColor.getSecondaryContainerDark(Theme.of(context)) : Theme.of(context).colorScheme.surface,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Text("🌤"),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                "Open Meteo",
                                                style: TextStyle(
                                                    color: _isNight
                                                        ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                                        : Theme.of(context).colorScheme.onSurface),
                                              ),
                                            ),
                                            const Spacer(),
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
                                  InkWell(
                                    onTap: () {
                                      _sourceType = 1;
                                      _fabPageController.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                                      setState(() {});
                                    },
                                    child: Card(
                                      color: _isNight ? GetColor.getSecondaryContainerDark(Theme.of(context)) : Theme.of(context).colorScheme.surface,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 20,
                                                child: Image.asset(
                                                  "assets/logo_rm.png",
                                                  height: 30,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                "Weather Partner",
                                                style: TextStyle(
                                                    color: _isNight
                                                        ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                                        : Theme.of(context).colorScheme.onSurface),
                                              ),
                                            ),
                                            const Spacer(),
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
                                    _fabPageController.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                                  },
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () async {
                                    var res = await context.pushNamed("/ap$_sourceType");
                                    if (res == 0) {
                                      _fabAnimation.reverse();
                                    }
                                  },
                                  child: const Text("新增地點"),
                                )
                              ],
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box("Places").listenable(),
                                builder: (BuildContext context, Box<dynamic> value, Widget? child) {
                                  var allPlace = value.values.toList().where((element) => element["SourceType"] == _sourceType).toList();
                                  return ListView.builder(
                                    itemCount: allPlace.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Dismissible(
                                        key: Key(allPlace[index]["StationID"].toString()),
                                        confirmDismiss: (direction) async {
                                          return !allPlace[index]["LocationName"].toString().contains("IP所在地");
                                        },
                                        onDismissed: (direction) async {
                                          var box = Hive.box("Places");
                                          await box.deleteAt(box.values.toList().indexOf(allPlace[index]));
                                          var recent = Hive.box("RecentWeather");
                                          await recent.delete(allPlace[index]["StationID"]);
                                          if (_placeInfo["LocationName"] == allPlace[index]["LocationName"]) {
                                            handleNoPlaces(1);
                                          }
                                        },
                                        child: InkWell(
                                          onTap: () async {
                                            _fabAnimation.reverse();
                                            var box = Hive.box("RecentWeather");
                                            _placeInfo = {
                                              "SourceType": allPlace[index]["SourceType"],
                                              "StationID": allPlace[index]["StationID"],
                                              "LocationName": allPlace[index]["LocationName"]
                                            };
                                            await box.put("PlaceInfo", _placeInfo);
                                            if (allPlace[index]["SourceType"] == 0) {
                                              var lonlat = allPlace[index]["StationID"].toString().split(",");
                                              var weatherInfo = await getWeatherInfo(allPlace[index]["LocationName"], lonlat[0], lonlat[1]);
                                              var weatherBox = Hive.box("RecentWeather");
                                              await weatherBox.put(allPlace[index]["StationID"], weatherInfo);
                                            }
                                            if (allPlace[index]["SourceType"] == 1) {
                                              var weatherBox = Hive.box("RecentWeather");
                                              var weatherInfo =
                                                  await getWeatherPartner(allPlace[index]["LocationName"], allPlace[index]["StationID"]);
                                              await weatherBox.put(allPlace[index]["StationID"], weatherInfo);
                                            }
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
                                                allPlace[index]["StationID"].toString(),
                                                style: TextStyle(
                                                    color: _isNight
                                                        ? GetColor.getOnSecondaryContainerDark(Theme.of(context))
                                                        : Theme.of(context).colorScheme.onSurface),
                                              ),
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

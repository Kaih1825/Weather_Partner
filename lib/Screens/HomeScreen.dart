import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:weather_partner/Functions/WeatherInfo.dart';
import 'package:weather_partner/Utils/GetColor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  var _sourceType = 0;
  final _fabPageController = PageController();
  late final _fabAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final _fabTween = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fabAnimation, curve: Curves.easeInOut));
  late final _refreshAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  late final _refreshTween = Tween(begin: 0.0, end: 2 * pi * 90 / 360).animate(_refreshAnimation);
  var _placeInfo = {};
  var _isNight = false;

  @override
  void dispose() {
    _fabAnimation.dispose();
    _refreshAnimation.dispose();
    _fabPageController.dispose();
    super.dispose();
  }

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
    getWeatherInInit();

    recent.watch().listen((event) {
      try {
        if (event.value["StationID"] != null) {
          _placeInfo = {"SourceType": event.value["SourceType"], "StationID": event.value["StationID"], "LocationName": event.value["LocationName"]};
          print(event.value);
          if (event.value["SourceType"] == 0 && event.value["is_day"] != null) {
            _isNight = event.value["is_day"] == 0 ? true : false;
          }
          setState(() {});
        }
      } catch (ex) {}
    });

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_placeInfo.isNotEmpty) {
        if (_placeInfo["SourceType"] == 0) {
          var lonlat = _placeInfo["StationID"].toString().split(",");
          var weatherInfo = await getWeatherInfo(_placeInfo["LocationName"], lonlat[0], lonlat[1]);
          await recent.put(_placeInfo["StationID"], weatherInfo);
          _placeInfo = weatherInfo;
          if (_placeInfo["is_day"] != null) {
            _isNight = _placeInfo["is_day"] == 0 ? true : false;
          }
        }
        setState(() {});
      }
    });
    setState(() {});
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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
        await recent.put(_placeInfo["StationID"], weatherInfo);
        _placeInfo = weatherInfo;
        if (_placeInfo["is_day"] != null) {
          _isNight = _placeInfo["is_day"] == 0 ? true : false;
        }
      }
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
                  _placeInfo = tisWeatherInfo;
                  if (tisWeatherInfo["SourceType"] == 0) {
                    return Text("${tisWeatherInfo["LocationName"].toString()}\n${tisWeatherInfo["obsTime"].toString()}");
                  }
                }
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
                                      _fabPageController.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.linear);
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
                                              padding: EdgeInsets.symmetric(horizontal: 10),
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
                                    _fabPageController.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
                                  },
                                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () async {
                                    var res = await context.pushNamed("/ap0", queryParameters: {"Type": _sourceType.toString()});
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
                                  var allPlace = value.values.toList().where((element) => element["SourceType"] == _sourceType).toList();
                                  return ListView.builder(
                                    itemCount: allPlace.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () async {
                                          var box = Hive.box("RecentWeather");
                                          _placeInfo = {
                                            "SourceType": allPlace[index]["SourceType"],
                                            "StationID": allPlace[index]["StationID"],
                                            "LocationName": allPlace[index]["LocationName"]
                                          };
                                          await box.put("PlaceInfo", _placeInfo);
                                          var lonlat = allPlace[index]["StationID"].toString().split(",");
                                          _fabAnimation.reverse();
                                          var weatherInfo = await getWeatherInfo(allPlace[index]["LocationName"], lonlat[0], lonlat[1]);
                                          var weatherBox = Hive.box("RecentWeather");
                                          await weatherBox.put(allPlace[index]["StationID"], weatherInfo);
                                          _placeInfo = weatherInfo;
                                          if (_placeInfo["is_day"] != null) {
                                            _isNight = _placeInfo["is_day"] == 0 ? true : false;
                                          }
                                          setState(() {});
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

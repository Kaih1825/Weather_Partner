import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
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
  late final _fabTween =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fabAnimation, curve: Curves.easeInOut));
  var _placeInfo = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fabAnimation.addListener(() {
      setState(() {});
    });
    var recent = Hive.box("RecentWeather");
    _placeInfo = recent.get("PlaceInfo") ?? {};
    recent.watch().listen((event) {
      try {
        if (event.value["StationID"] != null) {
          _placeInfo = {"SourceType": event.value["SourceType"], "StationID": event.value["StationID"]};
          setState(() {});
        }
      } catch (ex) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetColor.getSurface(Theme.of(context)),
      floatingActionButton: Container(
        height: 70 + _fabTween.value * MediaQuery.of(context).size.height / 2,
        width: 70 + _fabTween.value * MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 + 10 * _fabTween.value),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
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
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      child: PageView(
                        controller: _fabPageController,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text("資料來源："),
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
                                        color: Theme.of(context).colorScheme.surface,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "assets/roc_cwa.png",
                                                width: 25,
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(("中央氣象署CWA")),
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
                                      icon: Icon(Icons.arrow_back_ios_new)),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.pushNamed("/ap", queryParameters: {"Type": _sourceType.toString()});
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
                                    return ListView.builder(
                                      itemCount: allPlace.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () {
                                            _placeInfo = {
                                              "SourceType": allPlace[index]["SourceType"],
                                              "StationID": allPlace[index]["StationID"]
                                            };
                                            setState(() {});
                                          },
                                          child: Card(
                                            color: Theme.of(context).colorScheme.surface,
                                            child: ListTile(
                                              title: Text(allPlace[index]["LocationName"].toString()),
                                              subtitle: Text(allPlace[index]["StationName"].toString()),
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
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              "assets/day_light.png",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: Platform.isMacOS || Platform.isWindows || Platform.isLinux ? 20 : 10),
            child: Builder(
              builder: (BuildContext context) {
                var box = Hive.box("RecentWeather");
                var tisWeatherInfo = box.get(_placeInfo["StationID"]);
                if (tisWeatherInfo != null) {
                  if (_placeInfo["SourceType"] == 0) {
                    return SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(tisWeatherInfo["locationName"]),
                          ],
                        ),
                      ),
                    );
                  }
                }
                return Text("無資料");
              },
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
            width: double.infinity,
            height: double.infinity,
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
}

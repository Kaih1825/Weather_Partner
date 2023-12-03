import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:weather_partner/Utils/GetColor.dart';

import '../Functions/WeatherInfo.dart';
import '../Utils/ApiKeys.dart';

class AddPlace0 extends StatefulWidget {
  const AddPlace0({super.key});

  @override
  State<AddPlace0> createState() => _AddPlace0State();
}

class _AddPlace0State extends State<AddPlace0> {
  var _result = [];
  var _coordinates = [];
  var _getting = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //Using maptiler api
  Future<void> _search(String keyword) async {
    _getting = 1;
    _result = [];
    _coordinates = [];
    setState(() {});
    var request = http.Request('GET', Uri.parse('https://api.maptiler.com/geocoding/$keyword.json?key=$maptiler'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = jsonDecode(await response.stream.bytesToString());
      var places = result["features"];
      for (var place in places) {
        var tisContext = [];
        try {
          for (var context in place["context"]) {
            if (context["kind"] == "admin_area" || context["kind"] == "place") {
              tisContext.add(context["text"]);
            }
          }
        } catch (ex) {}
        tisContext = tisContext.reversed.toSet().toList();
        if (place["properties"]["kind"] == "admin_area") {
          tisContext.add(place["text"]);
        }
        if (tisContext.length > 1) {
          _result.add(tisContext.toSet().toList());
          _coordinates.add(place["center"]);
        }
        setState(() {});
      }
      _getting = 0;
      if (_result.isEmpty) {
        _getting = 2;
      }
      setState(() {});
    } else {
      _getting = 2;
      setState(() {});
      if (kDebugMode) {
        print('https://api.maptiler.com/geocoding/$keyword.json?key=$maptiler');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: GetColor.getSurface(Theme.of(context)),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: kIsWeb
                    ? const EdgeInsets.symmetric(vertical: 10)
                    : Platform.isMacOS || Platform.isWindows || Platform.isLinux
                        ? const EdgeInsets.only(top: 20, bottom: 10)
                        : const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_sharp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: SearchBar(
                            key: const Key("SearchBar"),
                            onSubmitted: (keyword) {
                              _search(keyword);
                            },
                            leading: IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {},
                              icon: const Icon(Icons.search),
                            ),
                            hintText: "按送出鍵搜尋",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("位置資料來自:maptiler"),
                    if (_getting == 1)
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _result.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () async {
                              _getting = 1;
                              setState(() {});
                              var stationID = "${_coordinates[index][0].toString()},${_coordinates[index][1].toString()}";
                              var locationName = _result[index].toString().replaceAll(",", " ").replaceAll("[", "").replaceAll("]", "");
                              var box = Hive.box("Places");
                              var allPlace = box.values.toList();
                              var storageMap = {
                                "SourceType": 0,
                                "StationID": stationID,
                                "LocationName": locationName,
                              };
                              allPlace = allPlace.where((element) => element["StationID"] == stationID).toList();
                              if (allPlace.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("此地點已被新增過"),
                                  ),
                                );
                                return;
                              }
                              await box.add(storageMap);

                              var weatherInfo =
                                  await getWeatherInfo(locationName, _coordinates[index][0].toString(), _coordinates[index][1].toString());
                              var weatherBox = Hive.box("RecentWeather");
                              await weatherBox.put(stationID, weatherInfo);
                              await weatherBox.put("PlaceInfo", {
                                "SourceType": 0,
                                "StationID": stationID,
                                "LocationName": locationName,
                              });
                              _getting = 0;
                              context.pop(0);
                            },
                            child: Card(
                              color: GetColor.getSurfaceDim(Theme.of(context)),
                              child: ListTile(
                                title: Text(
                                  _result[index].toString().replaceAll(",", " ").replaceAll("[", "").replaceAll("]", ""),
                                ),
                                subtitle: Text(
                                  "經度:${_coordinates[index][0].toStringAsFixed(2).toString()}\n緯度:${_coordinates[index][1].toStringAsFixed(2).toString()}",
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_getting == 2)
                      const Center(
                        child: Text("搜尋失敗或沒有結果"),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

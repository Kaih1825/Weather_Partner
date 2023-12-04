import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:weather_partner/Functions/WeatherInfo.dart';

import '../Utils/GetColor.dart';

class AddPlace1 extends StatefulWidget {
  const AddPlace1({super.key});

  @override
  State<AddPlace1> createState() => _AddPlace1State();
}

class _AddPlace1State extends State<AddPlace1> {
  var _getting = 0;
  var _result = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parseJson();
  }

  void parseJson() async {
    _getting = 1;
    var request = http.Request('GET', Uri.parse('https://ohhfuck.ddns.net/data'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      _result = jsonDecode(await response.stream.bytesToString())["data"];
      _getting = 0;
      setState(() {});
    } else {}
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
                            onSubmitted: (keyword) async {
                              _getting = 1;
                              var request = http.Request('GET', Uri.parse('https://ohhfuck.ddns.net/data'));
                              http.StreamedResponse response = await request.send();
                              if (response.statusCode == 200) {
                                _result = jsonDecode(await response.stream.bytesToString())["data"];
                                _result = _result.where((element) => element["location"].toString().contains(keyword)).toList();
                                _getting = 0;
                                setState(() {});
                              } else {
                                _getting = 2;
                                setState(() {});
                              }
                              if (_result.isEmpty) {
                                _getting = 2;
                                setState(() {});
                              }
                            },
                            onChanged: (keyword) async {
                              if (keyword.isEmpty) {
                                _getting = 1;
                                var request = http.Request('GET', Uri.parse('https://ohhfuck.ddns.net/data'));
                                http.StreamedResponse response = await request.send();
                                if (response.statusCode == 200) {
                                  _result = jsonDecode(await response.stream.bytesToString())["data"];
                                  _getting = 0;
                                  setState(() {});
                                } else {}
                              }
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
              if (_getting == 1)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
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
                              var stationID = _result[index]["uuid"];
                              var locationName = _result[index]["location"];
                              var box = Hive.box("Places");
                              var allPlace = box.values.toList();
                              var storageMap = {
                                "SourceType": 1,
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

                              var weatherInfo = getWeatherPartner(locationName, stationID);

                              var weatherBox = Hive.box("RecentWeather");
                              await weatherBox.put(stationID, await weatherInfo);
                              await weatherBox.put("PlaceInfo", {
                                "SourceType": 1,
                                "StationID": stationID,
                                "LocationName": locationName,
                              });
                              _getting = 0;
                              context.pop(0);
                            },
                            child: Card(
                              color: GetColor.getSurfaceDim(Theme.of(context)),
                              child: ListTile(
                                title: Text(_result[index]["location"]),
                                subtitle: Text("${_result[index]["uuid"]}"),
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
                    if (_getting == 3)
                      const Center(
                        child: Text("失敗"),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

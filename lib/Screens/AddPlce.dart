import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:weather_partner/ApiKeys/ApiKeys.dart';
import 'package:weather_partner/Utils/GetColor.dart';

class AddPlace extends StatefulWidget {
  final int placeType;

  const AddPlace({super.key, required this.placeType});

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  get _placeType => widget.placeType;
  var _placeJson = [];
  var _searchResult = [];
  var _haveResult = true;
  final _searchBarKey = GlobalKey();
  var _connectedSattus = 200;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternet();
    if (_placeType == 0) {
      _getJson();
    }
  }

  void _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _connectedSattus = 200;
      }
    } on SocketException catch (_) {
      // _connected = false;
    }
  }

  void _getJson() async {
    if (_placeType == 0) {
      var response = await http.get(
        Uri.https('opendata.cwa.gov.tw', 'api/v1/rest/datastore/O-A0003-001',
            {"Authorization": cwaKeys, "elementName": "TIME"}),
      );
      _placeJson = jsonDecode(response.body)["records"]["location"];
    }
    setState(() {});
  }

  void getWeather(String stationID, String locationName) async {
    var response = await http.get(
      Uri.https('opendata.cwa.gov.tw', 'api/v1/rest/datastore/O-A0003-001',
          {"Authorization": cwaKeys, "stationId": stationID}),
    );
    var location = jsonDecode(response.body)["records"]["location"][0];
    var weatherElement = location["weatherElement"];
    var weatherMap = {};
    weatherMap["obsTime"] = location["time"]["obsTime"];
    weatherMap["locationName"] = location["locationName"];
    weatherMap["city"] = locationName.split(" ")[0];
    weatherMap["district"] = locationName.split(" ")[1];
    for (var tisElement in weatherElement) {
      weatherMap[tisElement["elementName"]] = tisElement["elementValue"];
    }
    var box = Hive.box("RecentWeather");
    await box.put(stationID, weatherMap);
    await box.put("PlaceInfo", {"SourceType": _placeType, "StationID": stationID});
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
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: SearchBar(
                          key: _searchBarKey,
                          leading: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {},
                            icon: const Icon(Icons.search),
                          ),
                          hintText: "搜尋",
                          onChanged: (keyword) {
                            if (keyword.isEmpty) {
                              _searchResult = [];
                            } else {
                              if (_placeType == 0) {
                                keyword = keyword.replaceAll("台", "臺");
                                keyword = keyword.replaceAll("鄉", "");
                                keyword = keyword.replaceAll("鎮", "");
                                keyword = keyword.replaceAll("市", "");
                                keyword = keyword.replaceAll("區", "");
                                keyword = keyword.replaceAll("縣", "");
                                keyword = keyword.replaceAll(" ", "");
                                _searchResult = _placeJson.where((element) {
                                  var parameter = element["parameter"];
                                  return element["locationName"].toString().contains(keyword) ||
                                      parameter[0]["parameterValue"].toString().contains(keyword) ||
                                      parameter[2]["parameterValue"].toString().contains(keyword);
                                }).toList();
                                var searchIndex = 0;
                                if (_searchResult.isEmpty) {
                                  for (var i = keyword.length; i > 0; i--) {
                                    var tisKeyword = keyword.substring(0, i);
                                    _searchResult = _placeJson.where((element) {
                                      var parameter = element["parameter"];
                                      return element["locationName"].toString().contains(tisKeyword) ||
                                          parameter[0]["parameterValue"].toString().contains(tisKeyword) ||
                                          parameter[2]["parameterValue"].toString().contains(tisKeyword);
                                    }).toList();
                                    if (_searchResult.isNotEmpty) {
                                      searchIndex = i;
                                      break;
                                    }
                                  }
                                  var tmp = _searchResult;
                                  if (_searchResult.isEmpty || searchIndex < keyword.length / 2 + 1) {
                                    _searchResult = _placeJson.where((element) {
                                      var parameter = element["parameter"];
                                      return element["locationName"].toString().contains(keyword[keyword.length - 1]) ||
                                          parameter[0]["parameterValue"]
                                              .toString()
                                              .contains(keyword[keyword.length - 1]) ||
                                          parameter[2]["parameterValue"]
                                              .toString()
                                              .contains(keyword[keyword.length - 1]);
                                    }).toList();
                                  }
                                  if (_searchResult.isEmpty) {
                                    _searchResult = tmp;
                                  }
                                }

                                setState(() {});
                              }
                            }
                            _haveResult = !(_searchResult.isEmpty && keyword.isNotEmpty);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_placeType == 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("資料來自於中央氣象署開放資料平台"),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    if (!_haveResult) const Center(child: Text("沒有結果")),
                    if (_haveResult && _searchResult.isEmpty) const Center(child: Text("請輸入關鍵字搜尋")),
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 25),
                      itemCount: _searchResult.length,
                      itemBuilder: (BuildContext context, int index) {
                        var tis = _searchResult[index];
                        var parameter = tis["parameter"];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () async {
                              if (_placeType == 0) {
                                var storageMap = {
                                  "SourceType": 0,
                                  "StationID": tis["stationId"],
                                  "LocationName": "${parameter[0]["parameterValue"]} ${parameter[2]["parameterValue"]}",
                                  "StationName": tis["locationName"],
                                };
                                var box = Hive.box("Places");
                                var allPlace = box.values.toList();
                                allPlace =
                                    allPlace.where((element) => element["StationID"] == tis["stationId"]).toList();
                                if (allPlace.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("此地點已被新增過")));
                                  return;
                                }
                                await box.add(storageMap);
                                getWeather(tis["stationId"],
                                    "${parameter[0]["parameterValue"]} ${parameter[2]["parameterValue"]}");
                                context.pop(0);
                              }
                            },
                            child: Card(
                              color: GetColor.getSurfaceDim(Theme.of(context)),
                              child: ListTile(
                                title: Text("${parameter[0]["parameterValue"]} ${parameter[2]["parameterValue"]}"),
                                subtitle: Text(tis["locationName"]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

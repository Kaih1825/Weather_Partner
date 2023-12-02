import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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
    var request = http.Request('GET', Uri.parse('http://202.5.226.152/data'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      _result = jsonDecode(await response.stream.bytesToString())["data"];
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
                            onSubmitted: (keyword) {},
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
                              // _getting = 1;
                              // setState(() {});
                              // var stationID = "${_coordinates[index][0].toString()},${_coordinates[index][1].toString()}";
                              // var locationName = _result[index].toString().replaceAll(",", " ").replaceAll("[", "").replaceAll("]", "");
                              // var box = Hive.box("Places");
                              // var allPlace = box.values.toList();
                              // var storageMap = {
                              //   "SourceType": 0,
                              //   "StationID": stationID,
                              //   "LocationName": locationName,
                              // };
                              // allPlace = allPlace.where((element) => element["StationID"] == stationID).toList();
                              // if (allPlace.isNotEmpty) {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     const SnackBar(
                              //       content: Text("此地點已被新增過"),
                              //     ),
                              //   );
                              //   return;
                              // }
                              // await box.add(storageMap);
                              //
                              // var weatherInfo =
                              // await getWeatherInfo(locationName, _coordinates[index][0].toString(), _coordinates[index][1].toString());
                              // var weatherBox = Hive.box("RecentWeather");
                              // await weatherBox.put(stationID, weatherInfo);
                              // await weatherBox.put("PlaceInfo", {
                              //   "SourceType": 0,
                              //   "StationID": stationID,
                              //   "LocationName": locationName,
                              // });
                              // _getting = 0;
                              // context.pop(0);
                            },
                            child: Card(
                              color: GetColor.getSurfaceDim(Theme.of(context)),
                              child: const ListTile(
                                title: Text("Name"),
                                subtitle: Text(
                                  "經度:\n緯度:",
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

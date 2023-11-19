import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:weather_partner/Utils/GetColor.dart';

import '../ApiKeys/ApiKeys.dart';

class AddPlace0 extends StatefulWidget {
  final int placeType;

  const AddPlace0({super.key, required this.placeType});

  @override
  State<AddPlace0> createState() => _AddPlace0State();
}

class _AddPlace0State extends State<AddPlace0> {
  var _result = [];
  var _coordinates = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _search(String keyword) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.maptiler.com/geocoding/$keyword.json?key=$maptiler'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _result = [];
      _coordinates = [];
      var result = jsonDecode(await response.stream.bytesToString());
      var places = result["features"];
      for (var place in places) {
        var tisContext = [];
        for (var context in place["context"]) {
          if (context["kind"] == "admin_area" || context["kind"] == "place") {
            tisContext.add(context["text"]);
          }
        }
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
      print(_result);
    } else {
      print("Error:${response.reasonPhrase}");
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
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder()),
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
                            onChanged: (keyword) {
                              _search(keyword);
                            },
                            leading: IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {},
                              icon: const Icon(Icons.search),
                            ),
                            hintText: "搜尋",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("位置資料來自:maptiler"),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _result.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        onTap: () async {
                          var box = Hive.box("Places");
                          var allPlace = box.values.toList();
                          var storageMap = {
                            "SourceType": 0,
                            "StationID":
                                "${_coordinates[index][0]},${_coordinates[index][1]}",
                            "LocationName": _result[index]
                                .toString()
                                .replaceAll(",", " ")
                                .replaceAll("[", "")
                                .replaceAll("]", ""),
                          };
                          allPlace = allPlace
                              .where((element) =>
                                  element["StationID"] ==
                                  "${_coordinates[index][0]},${_coordinates[index][1]}")
                              .toList();
                          if (allPlace.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("此地點已被新增過"),
                              ),
                            );
                            return;
                          }
                          // await box.add(storageMap);

                          context.pop(0);
                        },
                        child: Card(
                          color: GetColor.getSurfaceDim(Theme.of(context)),
                          child: ListTile(
                            title: Text(
                              _result[index]
                                  .toString()
                                  .replaceAll(",", " ")
                                  .replaceAll("[", "")
                                  .replaceAll("]", ""),
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
              ),
            ],
          ),
        ));
  }
}

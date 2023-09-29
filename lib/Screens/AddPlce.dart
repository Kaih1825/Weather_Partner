import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getJson();
  }

  void _getJson() async {
    if (_placeType == 0) {
      var headers = {'Content-Type': 'application/json'};
      var response = await http.get(
          Uri.https(
              'opendata.cwa.gov.tw', 'api/v1/rest/datastore/O-A0003-001', {
            "Authorization": "CWA-01A2A774-BE8A-4345-97D6-70101152C593",
            "elementName": "TIME"
          }),
          headers: headers);
      _placeJson = jsonDecode(response.body)["records"]["location"];
    }
    setState(() {});
    print(_placeJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GetColor.getSurface(Theme.of(context)),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SearchBar(
                  leading: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  hintText: "搜尋",
                  onSubmitted: (keyword) {
                    if (_placeType == 0) {
                      _searchResult = _placeJson.where((element) {
                        var _parameter = element["parameter"];
                        return element["locationName"]
                                .toString()
                                .contains(keyword) ||
                            _parameter[0]["parameterValue"]
                                .toString()
                                .contains(keyword) ||
                            _parameter[2]["parameterValue"]
                                .toString()
                                .contains(keyword);
                      }).toList();

                      print(_searchResult);
                      setState(() {});
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (BuildContext context, int index) {
                    var _tis = _searchResult[index];
                    return Card(
                      child: Column(
                        children: [],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}

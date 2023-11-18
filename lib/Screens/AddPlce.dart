import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../ApiKeys/ApiKeys.dart';
import 'package:weather_partner/Utils/GetColor.dart';

class AddPlace0 extends StatefulWidget {
  final int placeType;

  const AddPlace0({super.key, required this.placeType});

  @override
  State<AddPlace0> createState() => _AddPlace0State();
}

class _AddPlace0State extends State<AddPlace0> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _search(String keyword) async {
    var request = http.Request('GET', Uri.parse('https://api.locationiq.com/v1/autocomplete?key=$LocationQ&q=$keyword&limit=5&dedupe=1&accept-language=zh'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
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
                            hintText: "搜尋",
                            onChanged: (keyword) {
                            },
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
                    Text("位置資料來自:LocationlQ"),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

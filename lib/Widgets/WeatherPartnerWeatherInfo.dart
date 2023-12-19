import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'Block.dart';

class WeatherPartnerWeatherInfo extends StatefulWidget {
  final Map<dynamic, dynamic> info;
  final bool isNight;

  const WeatherPartnerWeatherInfo({super.key, required this.info, required this.isNight});

  @override
  State<WeatherPartnerWeatherInfo> createState() => _WeatherPartnerWeatherInfoState();
}

class _WeatherPartnerWeatherInfoState extends State<WeatherPartnerWeatherInfo> {
  get info => widget.info;

  get _isNight => widget.isNight;

  String timeParse() {
    var time = info["time"].toString().split(" ");
    var hour = int.parse(time[1].split(":")[0]);
    if (time[2] == "PM" && hour != 12) {
      hour += 12;
    }
    return "${time[0].replaceAll("-", "/")} ${hour.toString()}:${time[1].split(":")[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          child: Column(
            children: [
              Text(
                info["LocationName"].toString().split(" ").last,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  leading: 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < info["LocationName"].toString().split(" ").length - 1; i++)
                          Text(
                            "${info["LocationName"].toString().split(" ")[i]}${i == info["LocationName"].toString().split(" ").length - 2 ? "" : " "}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            strutStyle: const StrutStyle(
                              forceStrutHeight: true,
                              leading: 0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNight ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DefaultTextStyle(
                        style: const TextStyle(fontSize: 15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "觀測時間",
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                timeParse(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Wrap(
                runAlignment: WrapAlignment.center,
                children: [
                  Block(
                    isnight: _isNight,
                    child: SizedBox(
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Symbols.device_thermostat,
                                color: Colors.white,
                              ),
                              Text(
                                "溫度",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["temp"]}°C"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Block(
                    isnight: _isNight,
                    child: SizedBox(
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Symbols.humidity_mid,
                                color: Colors.white,
                              ),
                              Text(
                                "相對濕度",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["wet"]}%"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Block(
                    isnight: _isNight,
                    child: SizedBox(
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Symbols.sunny,
                                color: Colors.white,
                              ),
                              Text(
                                "紫外線指數",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                                "${info["purple"]}（${double.parse(info["purple"]) > 10 ? "危險" : double.parse(info["purple"]) > 7 ? "過量" : double.parse(info["purple"]) >= 5 ? "高量" : double.parse(info["purple"]) >= 2 ? "中量" : "低量"}）"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Block(
                    isnight: _isNight,
                    child: SizedBox(
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Symbols.humidity_mid,
                                color: Colors.white,
                              ),
                              Text(
                                "是否正在降雨",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(info["water"] == "Yes" ? "是" : "否"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

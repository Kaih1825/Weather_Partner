import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'Block.dart';

class OpenMeteoWeatherInfo extends StatefulWidget {
  final Map<dynamic, dynamic> info;
  final bool isNight;

  const OpenMeteoWeatherInfo({super.key, required this.info, required this.isNight});

  @override
  State<OpenMeteoWeatherInfo> createState() => _OpenMeteoWeatherInfoState();
}

class _OpenMeteoWeatherInfoState extends State<OpenMeteoWeatherInfo> {
  get info => widget.info;

  get _isNight => widget.isNight;
  var _weatherDescriptions = {};
  final _uviScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parseWeatherDescriptionsJson();
  }

  void parseWeatherDescriptionsJson() async {
    _weatherDescriptions = await jsonDecode(await DefaultAssetBundle.of(context).loadString("assets/WeatherDescriptions.json"));
    _uviScrollController.jumpTo(_uviScrollController.position.maxScrollExtent / 24 * DateTime.now().hour);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
                child: Container(
                  decoration: BoxDecoration(
                    color: _isNight ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.15),
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
                            info["obsTime"].toString().replaceAll("-", "/"),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
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
                      child: Stack(
                        children: [
                          if (_weatherDescriptions.isNotEmpty)
                            Center(
                              child: Image.network(
                                _weatherDescriptions["${info["CurrentWeather"]["weather_code"]}"][_isNight ? "night" : "day"]["image"],
                                width: 80,
                              ),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              if (_weatherDescriptions.isNotEmpty)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                      _weatherDescriptions["${info["CurrentWeather"]["weather_code"]}"][_isNight ? "night" : "day"]["description"]),
                                ),
                            ],
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
                            child: Text("${info["CurrentWeather"]["temperature_2m"]}°C"),
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
                                Symbols.device_thermostat,
                                color: Colors.white,
                              ),
                              Text(
                                "體感溫度",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["CurrentWeather"]["apparent_temperature"]}°C"),
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
                            child: Text("${info["CurrentWeather"]["relative_humidity_2m"]}%"),
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
                                "降雨量",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["CurrentWeather"]["precipitation"]}mm"),
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
                                Symbols.cloud,
                                color: Colors.white,
                              ),
                              Text(
                                "雲層覆蓋",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["CurrentWeather"]["cloud_cover"]}%"),
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
                          Row(
                            children: [
                              const Icon(
                                Symbols.air,
                                color: Colors.white,
                              ),
                              const Text(
                                "風向",
                              ),
                              const Spacer(),
                              Transform.rotate(
                                angle: (info["CurrentWeather"]["wind_direction_10m"]) * pi / 180,
                                child: const Icon(
                                  Icons.navigation,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["CurrentWeather"]["wind_direction_10m"]}°"),
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
                                Symbols.air,
                                color: Colors.white,
                              ),
                              Text(
                                "風速",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text("${info["CurrentWeather"]["wind_speed_10m"]}km/h"),
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
                                Symbols.air,
                                color: Colors.white,
                              ),
                              Text(
                                "陣風風速",
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "${info["CurrentWeather"]["wind_gusts_10m"]}km/h",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isNight ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "今日紫外線指數",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width - 40,
                        height: 250,
                        child: ScrollbarTheme(
                          data: const ScrollbarThemeData(mainAxisMargin: 10),
                          child: Scrollbar(
                            controller: _uviScrollController,
                            child: SingleChildScrollView(
                              controller: _uviScrollController,
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 15),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 22.0, left: 18.0, top: 34, bottom: 12),
                                  child: AspectRatio(
                                    aspectRatio: 8,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              for (var i = 0; i < 24; i++)
                                                SizedBox(
                                                  width: 30,
                                                  child: Center(
                                                    child: Text(
                                                      "${i}時",
                                                      style: const TextStyle(color: Colors.white),
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 3, right: 20),
                                            child: LineChart(
                                              LineChartData(
                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                lineTouchData: const LineTouchData(
                                                  enabled: false,
                                                ),
                                                backgroundColor: Colors.transparent,
                                                gridData: const FlGridData(
                                                  drawHorizontalLine: false,
                                                  drawVerticalLine: false,
                                                ),
                                                titlesData: const FlTitlesData(
                                                    rightTitles: AxisTitles(),
                                                    topTitles: AxisTitles(),
                                                    leftTitles: AxisTitles(),
                                                    bottomTitles: AxisTitles()),
                                                lineBarsData: [
                                                  LineChartBarData(
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.blue,
                                                        Colors.green,
                                                      ],
                                                    ),
                                                    dotData: FlDotData(
                                                      show: true,
                                                      getDotPainter: (spot, percent, barData, index) {
                                                        return FlDotCirclePainter(
                                                          radius: 3,
                                                          color: Colors.white,
                                                        );
                                                      },
                                                    ),
                                                    spots: [
                                                      for (var i = 0; i < 24; i++)
                                                        FlSpot(i.toDouble(), info["HourlyWeather"]["uv_index"][i] as double),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        //Add texts under every dot
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              for (var i = 0; i < 24; i++)
                                                SizedBox(
                                                  width: 30,
                                                  child: Text(
                                                    "${info["HourlyWeather"]["uv_index"][i].round()}\n${info["HourlyWeather"]["uv_index"][i].round() > 10 ? "危險" : info["HourlyWeather"]["uv_index"][i].round() > 7 ? "過量" : info["HourlyWeather"]["uv_index"][i].round() >= 5 ? "高量" : info["HourlyWeather"]["uv_index"][i].round() >= 2 ? "中量" : "低量"}",
                                                    style: const TextStyle(color: Colors.white),
                                                    softWrap: false,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

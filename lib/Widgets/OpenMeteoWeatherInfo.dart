import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
  var _dailyIndex = 0;
  final _uviScrollController = ScrollController();
  final _dailyPageContrller = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parseWeatherDescriptionsJson();
    initializeDateFormatting();
  }

  void parseWeatherDescriptionsJson() async {
    _weatherDescriptions = await jsonDecode(await DefaultAssetBundle.of(context).loadString("assets/WeatherDescriptions.json"));
    _uviScrollController.jumpTo(_uviScrollController.position.maxScrollExtent / 24 * DateTime.now().hour);

    setState(() {});
  }

  @override
  void dispose() {
    _uviScrollController.dispose();
    _dailyPageContrller.dispose();
    super.dispose();
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
                                info["obsTime"].toString().replaceAll("-", "/"),
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
                      child: Stack(
                        children: [
                          if (_weatherDescriptions.isNotEmpty)
                            Center(
                              child: Image.network(
                                  _weatherDescriptions["${info["CurrentWeather"]["weather_code"]}"][_isNight ? "night" : "day"]["image"],
                                  width: 80, errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  width: 0,
                                  height: 0,
                                );
                              }),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNight ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.4),
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
                            width: MediaQuery.of(context).size.width - 40,
                            height: 250,
                            child: Center(
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
                                                            "$i時",
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNight ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "7日天氣預測",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Expanded(
                                child: PageView(
                                  controller: _dailyPageContrller,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: info["DailyWeather"]["time"].length,
                                        itemBuilder: (BuildContext context, int index) {
                                          var daily = info["DailyWeather"];
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                _dailyIndex = index;
                                                _dailyPageContrller.animateToPage(1,
                                                    duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                                              });
                                            },
                                            child: SizedBox(
                                              height: 50,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    index == 0
                                                        ? "今天　"
                                                        : index == 1
                                                            ? "明天　"
                                                            : index == 2
                                                                ? "後天　"
                                                                : DateFormat("EEEE", "zh_TW").format(
                                                                    DateTime.parse(daily["time"][index].toString()),
                                                                  ),
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                  ),
                                                  if (_weatherDescriptions.isNotEmpty)
                                                    Center(
                                                      child: Image.network(_weatherDescriptions["${daily["weather_code"][index]}"]["day"]["image"],
                                                          width: 80, errorBuilder: (context, error, stackTrace) {
                                                        return Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            _weatherDescriptions["${daily["weather_code"][index]}"]["day"]["description"],
                                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  const Spacer(),
                                                  Text(
                                                    "${daily["temperature_2m_max"][index].toString().split(".")[0]}°C / ${daily["temperature_2m_min"][index].toString().split(".")[0]}°C",
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                  ),
                                                  const Icon(Icons.navigate_next, color: Colors.white),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Builder(builder: (context) {
                                      var daily = info["DailyWeather"];
                                      var index = _dailyIndex;
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    _dailyPageContrller.animateToPage(0,
                                                        duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                                                  },
                                                  icon: const Icon(Icons.navigate_before, color: Colors.white)),
                                              Text(
                                                DateFormat("yyyy/MM/dd　", "zh_TW").format(
                                                  DateTime.parse(daily["time"][index].toString()),
                                                ),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                              ),
                                              Text(
                                                DateFormat("EEEE", "zh_TW").format(
                                                  DateTime.parse(daily["time"][index].toString()),
                                                ),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: [
                                                        Container(
                                                          height: 90,
                                                          width: 200 * 2 > MediaQuery.of(context).size.width - 20
                                                              ? MediaQuery.of(context).size.width / 2 - 10
                                                              : 200,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: _isNight ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.3),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              if (_weatherDescriptions.isNotEmpty)
                                                                Center(
                                                                  child: Image.network(
                                                                      _weatherDescriptions["${daily["weather_code"][index]}"]["day"]["image"],
                                                                      height: 80, errorBuilder: (context, error, stackTrace) {
                                                                    return Text(
                                                                      _weatherDescriptions["${daily["weather_code"][index]}"]["day"]["description"],
                                                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                                    );
                                                                  }),
                                                                ),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  const Spacer(),
                                                                  if (_weatherDescriptions.isNotEmpty)
                                                                    Align(
                                                                      alignment: Alignment.bottomRight,
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 9, right: 8),
                                                                        child: Text(
                                                                          _weatherDescriptions["${daily["weather_code"][index]}"]["day"]
                                                                              ["description"],
                                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        MinBlock(
                                                            title:
                                                                "最高溫 / 最低溫： ${daily["temperature_2m_max"][index].toString().split(".")[0]}°C / ${daily["temperature_2m_min"][index].toString().split(".")[0]}°C",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title:
                                                                "體感最高溫 / 體感最低溫： ${daily["apparent_temperature_max"][index].toString().split(".")[0]}°C / ${daily["apparent_temperature_min"][index].toString().split(".")[0]}°C",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title:
                                                                "日出 / 日落： ${DateFormat("HH:mm", "zh_TW").format(DateTime.parse(daily["sunrise"][index].toString()))} / ${DateFormat("HH:mm", "zh_TW").format(DateTime.parse(daily["sunset"][index].toString()))}",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title:
                                                                "最大紫外線指數： ${daily["uv_index_max"][index].toString().split(".")[0]} (${daily["uv_index_max"][index].round() > 10 ? "危險" : daily["uv_index_max"][index].round() > 7 ? "過量" : daily["uv_index_max"][index].round() >= 5 ? "高量" : daily["uv_index_max"][index].round() >= 2 ? "中量" : "低量"})",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title: "降雨量： ${daily["precipitation_sum"][index].toString().split(".")[0]}mm",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title: "降雨時數： ${daily["precipitation_hours"][index].toString().split(".")[0]}小時",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title: "降雨機率： ${daily["precipitation_probability_max"][index].toString().split(".")[0]}%",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title: "最大風速： ${daily["wind_speed_10m_max"][index].toString().split(".")[0]}km/h",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title: "最大陣風： ${daily["wind_gusts_10m_max"][index].toString().split(".")[0]}km/h",
                                                            isnight: _isNight),
                                                        MinBlock(
                                                            title: "主要風向： ${daily["wind_direction_10m_dominant"][index].toString().split(".")[0]}°",
                                                            isnight: _isNight),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              )
                            ],
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
    );
  }
}

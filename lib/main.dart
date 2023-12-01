import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:window_size/window_size.dart';

import 'Screens/AddPlce.dart';
import 'Screens/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('天氣夥伴 Weather Partner');
    setWindowMinSize(const Size(450, 300));
    setWindowMaxSize(Size.infinite);
  }
  await Hive.initFlutter();
  await Hive.openBox("Places");
  await Hive.openBox("RecentWeather");
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  static final _defaultLightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light);
  static final _defaultDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return TooltipVisibility(
          visible: true,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true, colorScheme: lightDynamic ?? _defaultLightColorScheme),
            darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: darkDynamic ?? _defaultDarkColorScheme),
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: "/",
                  builder: (context, state) {
                    return const HomeScreen();
                  },
                ),
                GoRoute(
                    name: "/ap0",
                    path: "/AddPlace0",
                    builder: (context, state) {
                      return AddPlace0(placeType: int.parse(state.uri.queryParameters["Type"].toString()));
                    })
              ],
            ),
          ),
        );
      },
    );
  }
}

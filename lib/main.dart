import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'Screens/AddPlace0.dart';
import 'Screens/AddPlace1.dart';
import 'Screens/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Weather Partner');
    setWindowMinSize(const Size(450, 300));
    setWindowMaxSize(Size.infinite);
  }
  if (!kIsWeb) {
    final suppDir = await getApplicationSupportDirectory();
    await Hive.initFlutter(suppDir.path);
  } else {
    Hive.initFlutter();
  }
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
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
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
                    return const AddPlace0();
                  },
                ),
                GoRoute(
                  name: "/ap1",
                  path: "/AddPlace1",
                  builder: (context, state) {
                    return const AddPlace1();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

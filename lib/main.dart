import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.pink, brightness: Brightness.light);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: lightDynamic ?? _defaultLightColorScheme),
          darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: darkDynamic ?? _defaultDarkColorScheme),
          home: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Save",
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

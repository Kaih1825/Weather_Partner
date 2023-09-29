import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_partner/Screens/AddPlce.dart';
import 'package:weather_partner/Utils/GetColor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _sourceType = 0;
  var _scrollUpLineIsTouching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetColor.getSurface(Theme.of(context)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            height: double.infinity,
            child: const Text("sss"),
          ),
          DraggableScrollableSheet(
            snap: true,
            minChildSize: 0.1,
            initialChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return NotificationListener(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    _scrollUpLineIsTouching = true;
                    setState(() {});
                  } else if (scrollNotification is ScrollEndNotification) {
                    _scrollUpLineIsTouching = false;
                    setState(() {});
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                        color: GetColor.getSurfaceContainer(Theme.of(context)),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 60,
                                      height: 10,
                                      child: InkWell(
                                        onTapDown: (_) {
                                          _scrollUpLineIsTouching = true;
                                          setState(() {});
                                        },
                                        onTapUp: (_) {
                                          _scrollUpLineIsTouching = false;
                                          setState(() {});
                                        },
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 50 +
                                                (10 *
                                                    (_scrollUpLineIsTouching
                                                        ? 1
                                                        : 0)),
                                            height: 8 +
                                                (2 *
                                                    (_scrollUpLineIsTouching
                                                        ? 1
                                                        : 0)),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outlineVariant,
                                                borderRadius:
                                                    BorderRadius.circular(40)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: Colors.transparent,
                                    ),
                                    child: BottomNavigationBar(
                                      backgroundColor: Colors.transparent,
                                      onTap: (v) {
                                        setState(() {
                                          _sourceType = v;
                                        });
                                      },
                                      elevation: 0,
                                      currentIndex: _sourceType,
                                      items: [
                                        BottomNavigationBarItem(
                                          icon: SvgPicture.asset(
                                            "assets/roc_cwa.svg",
                                            colorFilter: ColorFilter.mode(
                                                _sourceType == 0
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                BlendMode.srcIn),
                                            width: 30,
                                          ),
                                          label: "中央氣象署",
                                        ),
                                        const BottomNavigationBarItem(
                                          icon: Icon(Icons.cloud),
                                          label: "CBC",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "地點：",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return AddPlace(
                                              placeType: _sourceType,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [Icon(Icons.add), Text("新增地點")],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: NotificationListener(
                                  onNotification: (n) {
                                    return true;
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: 100,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return const Text("ss");
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_partner/Utils/GetColor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var controller = ScrollController();
  var sourceType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetColor.getSurface(Theme.of(context)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: GetColor.getSurface(Theme.of(context)),
            height: double.infinity,
            child: const Text("sss"),
          ),
          DraggableScrollableSheet(
            snap: true,
            minChildSize: 0.1,
            initialChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  controller: scrollController,
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(40)),
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
                                    sourceType = v;
                                  });
                                },
                                elevation: 0,
                                currentIndex: sourceType,
                                items: [
                                  BottomNavigationBarItem(
                                    icon: SvgPicture.asset(
                                      "assets/roc_cwa.svg",
                                      colorFilter: ColorFilter.mode(
                                          sourceType == 0
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
                      );
                    }
                    return Text(index.toString());
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

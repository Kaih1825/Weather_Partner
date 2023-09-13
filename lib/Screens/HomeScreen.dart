import 'package:flutter/material.dart';
import 'package:weather_partner/Utils/GetColor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var controller = ScrollController();
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
            minChildSize: 0.1,
            initialChildSize: 0.1,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 10,
                              color: GetColor.getOnSurfaceVariant(
                                  Theme.of(context)),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.abc)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          controller: scrollController,
                          itemCount: 50,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text("Item$index"),
                            );
                          },
                        ),
                      ),
                    ],
                  ));
            },
          )
        ],
      ),
    );
  }
}

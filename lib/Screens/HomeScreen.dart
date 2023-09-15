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
                                  borderRadius: BorderRadius.circular(40)
                                ),
                              ),
                            ),
                            IconButton(onPressed: (){}, icon: Icon(Icons.abc))
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

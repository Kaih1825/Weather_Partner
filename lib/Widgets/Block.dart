import 'dart:ui';

import 'package:flutter/material.dart';

class Block extends StatefulWidget {
  final Widget child;
  final bool isnight;

  const Block({super.key, required this.child, required this.isnight});

  @override
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {
  get child => widget.child;

  get _isNight => widget.isnight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: _isNight ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(),
              child: SizedBox(
                width: 180 * 2 > MediaQuery.of(context).size.width - 50 ? MediaQuery.of(context).size.width / 2 - 30 : 180,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: ClipRect(child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MinBlock extends StatefulWidget {
  final String title;
  final bool isnight;

  const MinBlock({super.key, required this.title, required this.isnight});

  @override
  State<MinBlock> createState() => _MinBlockState();
}

class _MinBlockState extends State<MinBlock> {
  get title => widget.title.split("： ");

  get _isNight => widget.isnight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 200 * 2 > MediaQuery.of(context).size.width - 20 ? MediaQuery.of(context).size.width / 2 - 10 : 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _isNight ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title[0], style: const TextStyle(color: Colors.white)),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(title[1], style: const TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

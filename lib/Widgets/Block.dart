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
      padding: const EdgeInsets.only(top: 15, left: 6, right: 6),
      child: Container(
        decoration: BoxDecoration(
          color: _isNight ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: SizedBox(
              width: 70,
              height: 100,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

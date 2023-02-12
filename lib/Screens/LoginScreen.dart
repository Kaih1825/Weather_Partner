import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Widgets/Circle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
//AAAA
class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 0, 147, 233),
            Color.fromARGB(255, 128, 208, 199)
          ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: const [
                    Positioned(
                    width: 200,
                    height: 200,
                    top: -40,
                    right: -50,
                    child: Circle(),
                  ),
                  ]
                ),
              ),
              Expanded(
                child: Stack(
                  children: const [
                    Positioned(
                    width: 200,
                    height: 200,
                    bottom: -80,
                    left: -40,
                    child: Circle(),
                  ),
                  ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



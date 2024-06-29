import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  final startAlignment = Alignment.topLeft;
  final endAlignment = Alignment.bottomRight;
  final List<Widget> children;

  const BackGround({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: const [
          Color.fromARGB(255, 121, 190, 255),
          Color.fromARGB(255, 39, 125, 255)
        ],
        begin: startAlignment,
        end: endAlignment,
      )),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

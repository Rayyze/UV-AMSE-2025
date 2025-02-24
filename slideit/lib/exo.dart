import 'dart:math';
import 'package:flutter/material.dart';

class Ex1 extends StatefulWidget {
  const Ex1({super.key});

  @override
  State<Ex1> createState() => _Ex1State();
}

class _Ex1State extends State<Ex1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Exercice 1"),
      ),
      body: Image.network("https://picsum.photos/1920/1080?random=${Random().nextInt(10000)}")
    );
  }
}

class Ex2 extends StatefulWidget {
  const Ex2({super.key});

  @override
  State<Ex2> createState() => _Ex2State();
}

class _Ex2State extends State<Ex2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Exercice 1"),
      ),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(color: Colors.white),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateX(1.0) ..rotateZ(1.0)..scale(1.0),
          child: Image.network(
            "https://picsum.photos/1920/1080?random=${Random().nextInt(10000)}",
          ),
        ),
      ),
    );
  }
}
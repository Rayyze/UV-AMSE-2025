import 'package:flutter/material.dart';
import 'package:slideit/exo.dart';
import 'package:slideit/game.dart';
import 'package:slideit/styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlideIt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CustomTextButton(
              width: buttonWidth,
              text: "CONTINUE", 
              action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Game(continueGame: true, size: 3, shuffleCount: 10,)));
              },
            ),
            SizedBox(height: 20),
            CustomTextButton(
              width: buttonWidth,
              text: "NEW GAME", 
              action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Game(continueGame: false, size: 3, shuffleCount: 10,)));
              },
            ),
            SizedBox(height: 20),
            CustomTextButton(
              width: buttonWidth,
              text: "FEATURES", 
              action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExoPage(title: "Exercices")));
              },
            ),
            SizedBox(height: 20),
            CustomTextButton(
              width: buttonWidth,
              text: "SETTINGS", 
              action: () {
                
              },
            ),
            SizedBox(height: 20),
            CustomTextButton(
              width: buttonWidth,
              text: "EXIT", 
              action: () => Navigator.pop(context),
            ),
          ],
        ),
      )
    );
  }
}


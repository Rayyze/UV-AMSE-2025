import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slideit/exo.dart';
import 'package:slideit/game.dart';
import 'package:slideit/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });

    // Save the theme preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlueAccent,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      title: 'SlideIt',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(toggleTheme: toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MyHomePage({super.key, required this.toggleTheme});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int size = 3;
  int shuffleCount = 10;
  String difficultyLabel = "Easy";

  @override
  void initState() {
    size = 3;
    shuffleCount = 10;
    difficultyLabel = "Easy";
    super.initState();
  }

  void showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text("SETTINGS", textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Grid Size (Square)"),
                  Slider(
                    activeColor: Theme.of(context).primaryColor,
                    value: size.toDouble(),
                    min: 3,
                    max: 15,
                    divisions: 12,
                    label: size.toString(),
                    onChanged: (double value) {
                      setDialogState(() {
                        size = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Text("Difficulty"),
                  Slider(
                    activeColor: Theme.of(context).primaryColor,
                    value: shuffleCount.toDouble(),
                    min: 10,
                    max: 1010,
                    divisions: 10,
                    label: difficultyLabel,
                    onChanged: (double value) {
                      setDialogState(() {
                        shuffleCount = value.toInt();
                        difficultyLabel = "Peaceful";
                        if (shuffleCount > 0) difficultyLabel = "Very Easy";
                        if (shuffleCount > 100) difficultyLabel = "Easy";
                        if (shuffleCount > 200) difficultyLabel = "Medium";
                        if (shuffleCount > 300) difficultyLabel = "Challenging";
                        if (shuffleCount > 400) difficultyLabel = "Very Challenging";
                        if (shuffleCount > 500) difficultyLabel = "Hard";
                        if (shuffleCount > 600) difficultyLabel = "Very Hard";
                        if (shuffleCount > 700) difficultyLabel = "Expert";
                        if (shuffleCount > 800) difficultyLabel = "Expert+";
                        if (shuffleCount > 900) difficultyLabel = "Master";
                        if (shuffleCount > 1000) difficultyLabel = "Master+";
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        widget.toggleTheme();
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Theme.of(context).primaryColor,
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).primaryColor,
                    isSelected: [Theme.of(context).brightness == Brightness.light, Theme.of(context).brightness == Brightness.dark],
                    children: [Icon(Icons.light_mode), Icon(Icons.dark_mode)],
                  ),
                ],
              ),
              actions: [
                CustomTextButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  text: "APPLY & CLOSE", 
                  width: MediaQuery.of(context).size.width * 0.7, 
                  action: () {
                    saveSettings();
                    Navigator.pop(context);
                  }
                )
              ],
            );
          }
        );
      },
    );
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("sizeSetting", size);
    await prefs.setInt("shuffleSetting", shuffleCount);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(8),
              child: Theme.of(context).brightness == Brightness.light ? Image.asset("icon_cropped.png") : Image.asset("icon_cropped_dark.png"),
            ),
            SizedBox(height: 80),
            Column(
              children: [
                CustomTextButton(
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).primaryColor,
                  width: buttonWidth,
                  text: "CONTINUE", 
                  action: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Game(continueGame: true, size: 3, shuffleCount: 10,)));
                  },
                ),
                SizedBox(height: 20),
                CustomTextButton(
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).primaryColor,
                  width: buttonWidth,
                  text: "NEW GAME", 
                  action: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Game(continueGame: false, size: 3, shuffleCount: 10,)));
                  },
                ),
                SizedBox(height: 20),
                CustomTextButton(
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).primaryColor,
                  width: buttonWidth,
                  text: "FEATURES", 
                  action: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExoPage(title: "Exercices")));
                  },
                ),
                SizedBox(height: 20),
                CustomTextButton(
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).primaryColor,
                  width: buttonWidth,
                  text: "SETTINGS", 
                  action: () {
                    showSettings();
                  }
                ),
                SizedBox(height: 20),
                CustomTextButton(
                  backgroundColor: Colors.redAccent,
                  width: buttonWidth,
                  text: "EXIT", 
                  action: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}


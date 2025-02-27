import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:slideit/main.dart';
import 'package:slideit/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Tile {
  Color color = Colors.white;
  bool empty = false;
  int index = 0;
  Widget img;

  Tile(this.index, this.empty, this.img);
}

class Game extends StatefulWidget {
  final bool continueGame;
  final int size;
  final int shuffleCount;

  const Game({super.key, required this.continueGame, required this.size, required this.shuffleCount});

  @override
  State<StatefulWidget> createState() => _GameState();
  
}

class _GameState extends State<Game> {
  static const int imgSize = 1080;
  String imageUrl = "https://picsum.photos/$imgSize?random=${Random().nextInt(10000)}";
  Image img = Image.network("https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930");
  int size = 3;
  int emptyIndex = -1;
  List<Widget> widgets = [];
  List<Tile> tiles = [];
  bool gameWon = false;
  bool gameReady = false;
  int minMoves = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }
  
  Future<void> startGame() async {
    if (widget.continueGame) {
      await loadGame();
      print("game loaded");
      updateWidgetList();
      setState(() {
        gameReady = true;
      });
    } else {
      img = Image.network(
        imageUrl,
        fit: BoxFit.scaleDown,
      );
      saveImage();
      tiles = getTileList();
      shuffle(widget.shuffleCount);
      updateWidgetList();
      setState(() {
        gameReady = true;
      });
    }
  }

  Future<void> saveImage() async {
    print("saving");
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      Uint8List  bytes = response.bodyBytes;
      String base64Image = base64Encode(bytes);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imageBase64', base64Image);
    }
  }

  Future<void> saveGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String> tileIndices = tiles.map((tile) => tile.index.toString()).toList();
    
    await prefs.setStringList('tiles', tileIndices);
    await prefs.setInt('emptyIndex', emptyIndex);
    await prefs.setInt('size', size);
    await prefs.setBool("continue", gameWon ? true : false);
  }

  Future<void> loadGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedTiles = prefs.getStringList('tiles');
    
    if (savedTiles != null) {
      setState(() {
        size = prefs.getInt('size') ?? 3;
        emptyIndex = prefs.getInt('emptyIndex') ?? -1;
        
        String? base64Image = prefs.getString('imageBase64');
  
        if (base64Image != null) {
          Uint8List  imageBytes = base64Decode(base64Image);
          img = Image.memory(imageBytes);
        }
        tiles = List.generate(size * size, (i) {
          int tileIndex = int.parse(savedTiles[i]);
          double alignX = (tileIndex % size) / (size - 1) * 2 - 1;
          double alignY = (tileIndex ~/ size) / (size - 1) * 2 - 1;
          return Tile(tileIndex, i == emptyIndex, croppedImageTile(1 / size, 1 / size, alignX, alignY));
        });
      });
    }
  }

  Widget croppedImageTile(double widthFactor, double heightFactor, double alignX, double alignY) {
    return FittedBox(
      fit: BoxFit.fill,
      child: ClipRect(
        child: Align(
          alignment: Alignment(alignX, alignY),
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: img
        ),
      ),
    );
  }

  List<Tile> getTileList() {
    final double tileRatio = 1/size;
    List<Tile> result = [];
    for (int i=0; i<size; i++) {
      for (int j=0; j<size; j++) {
        double alignY = (i / (size - 1)) * 2 - 1;
        double alignX = (j / (size - 1)) * 2 - 1;
        
        result.add(Tile(i*size + j, false, croppedImageTile(tileRatio, tileRatio, alignX, alignY)));
      }
    }
    emptyIndex = Random().nextInt(size*size);
    result[emptyIndex].empty = true;
    return result;
  }

  bool isNextToEmpty(int index) {
    bool sameRow = (index ~/ size) == (emptyIndex ~/ size);
    bool sameColumn = (index % size) == (emptyIndex % size);

    return (sameRow && (index == emptyIndex - 1 || index == emptyIndex + 1)) || (sameColumn && (index == emptyIndex - size || index == emptyIndex + size));
  }

  void swapTiles(int index) {
    if (gameWon) {
      return;
    }
    if (isNextToEmpty(index)) {
      Tile temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[index];
      tiles[index] = temp;
      emptyIndex = index;

      saveGame();
    }
  }

  void shuffle(int n) {
    for (int i=0; i<n; i++) {
      List<int> availableIndices = [];
      if (emptyIndex%size != size-1) availableIndices.add(emptyIndex+1);
      if (emptyIndex%size != 0) availableIndices.add(emptyIndex-1);
      if (emptyIndex~/size != size-1) availableIndices.add(emptyIndex + size);
      if (emptyIndex > size) availableIndices.add(emptyIndex-size);

      if (availableIndices.isNotEmpty) swapTiles(availableIndices[Random().nextInt(availableIndices.length)]);
    }
  }

  bool isGameWon() {
    for (int i=0; i<size*size; i++) {
      if (tiles[i].index != i) {
        return false;
      }
    }
    return true;
  }

  int getMinMoves(List<Tile> tiles, int size) {
    int manhattanDistance = 0;
    int linearConflict = 0;

    // Calculate manhattan distance
    for (Tile tile in tiles) {
      if (tile.empty) continue;

      int currentX = tile.index % size;
      int currentY = tile.index ~/ size;
      int goalX = (tile.index) % size; 
      int goalY = (tile.index) ~/ size;

      manhattanDistance += (goalX - currentX).abs() + (goalY - currentY).abs();
    }

    // Check for conflict in rows
    for (int row = 0; row < size; row++) {
      List<Tile> rowTiles = tiles.where((tile) => tile.index ~/ size == row && !tile.empty).toList();

      for (int i = 0; i < rowTiles.length; i++) {
        for (int j = i + 1; j < rowTiles.length; j++) {
          if (rowTiles[i].index % size > rowTiles[j].index % size) {
            linearConflict++;
          }
        }
      }
    }

    // Check for conflict in columns
    for (int col = 0; col < size; col++) {
      List<Tile> colTiles = tiles.where((tile) => tile.index % size == col && !tile.empty).toList();

      for (int i = 0; i < colTiles.length; i++) {
        for (int j = i + 1; j < colTiles.length; j++) {
          if (colTiles[i].index ~/ size > colTiles[j].index ~/ size) {
            linearConflict++;
          }
        }
      }
    }

    return manhattanDistance + (2 * linearConflict);
  }

  void updateWidgetList() {
    List<Widget> result = [];
    for(int i=0; i<tiles.length; i++) {
      Tile tile = tiles[i];
      result.add(
        InkWell(
          onTap: () {
            swapTiles(i);
            if (isGameWon()) {
              tiles[emptyIndex].empty = false;
              setState(() {
                gameWon = true;
                saveGame();
              });
            }
            updateWidgetList();
            setState(() {
              minMoves = getMinMoves(tiles, size);
            });
          },
          child: Stack(
            children: [
              (tile.empty)
              ? Container(
                color: tile.color,
                child: Padding(
                  padding: EdgeInsets.all(70.0),
                )
              ) : tile.img,
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(101, 255, 255, 255),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "${tile.index}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ]
          ),
        )
      );
    }
    
    setState(() {
      widgets = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gameReady ? Column(
        children: [
          gameWon ? Text("You won") : SizedBox.shrink(),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            crossAxisCount: size,
            children: widgets,
          ),
          SizedBox(height: 20),
          gameWon ? CustomTextButton(
            text: "NEW GAME", 
            width: MediaQuery.of(context).size.width * 0.8, 
            action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Game(continueGame: false, size: widget.size, shuffleCount: widget.shuffleCount)));
            }
          ) : CustomTextButton(
            text: "SAVE & QUIT", 
            width: MediaQuery.of(context).size.width * 0.8, 
            action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
            }
          )
        ],
      )
      : Column(
        children: [
          Expanded(
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              crossAxisCount: size,
              children: widgets,
            ),
          ),
        ],
      )
    );
  }
}
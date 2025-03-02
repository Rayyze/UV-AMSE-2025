import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:slideit/image_import.dart';
import 'package:slideit/sound_manager.dart';
import 'package:slideit/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final bool randomGame;

  const Game({super.key, required this.continueGame, required this.size, required this.shuffleCount, this.randomGame = true});

  @override
  State<StatefulWidget> createState() => _GameState();
  
}

class _GameState extends State<Game> {
  SoundManager soundManager = SoundManager();
  static const int imgSize = 1080;
  String imageUrl = "https://picsum.photos/$imgSize?random=${Random().nextInt(10000)}";
  Image img = Image.network("https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930");
  int size = 3;
  int emptyIndex = -1;
  int lastSwapIndex = -1;
  int moves = 0;
  List<Widget> widgets = [];
  List<Tile> tiles = [];
  bool gameWon = false;
  bool gameReady = false;
  bool showNumbers = true;
  bool canUndo = false;
  int minMoves = 0;
  int shuffleCount = 10;

  @override
  void initState() {
    super.initState();
    startGame();
  }
  
  Future<void> startGame() async {
    shuffleCount = widget.shuffleCount;
    if (widget.continueGame) {
      await loadGame();
    } else {
      if (widget.randomGame) {
        img = await fetchAndSaveImageRandom(imageUrl);
      } else {
        img = await fetchAndSaveImageGallery();
      }
      await loadSettings();
      tiles = getTileList();
      shuffle();
    }
    minMoves = getMinMoves(tiles, size);
    moves = 0;
    canUndo = false;
    updateWidgetList();
    setState(() {
      gameReady = true;
    });
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    size = prefs.getInt("sizeSetting") ?? 3;
    shuffleCount = prefs.getInt("shuffleSetting") ?? 10;
  }

  Future<void> saveGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String> tileIndices = tiles.map((tile) => tile.index.toString()).toList();
    
    await prefs.setStringList('tiles', tileIndices);
    await prefs.setInt('emptyIndex', emptyIndex);
    await prefs.setInt('size', size);
    await prefs.setBool("continue", gameWon ? false : true);
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
      soundManager.playSound("click.mp3");
      Tile temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[index];
      tiles[index] = temp;
      lastSwapIndex = emptyIndex;
      emptyIndex = index;
      moves+=1;

      
      saveGame();
    }
    
    canUndo = true;
  }

  void shuffle() {
    for (int i=0; i<shuffleCount; i++) {
      List<int> availableIndices = [];
      if (emptyIndex+1 != lastSwapIndex && emptyIndex%size != size-1) availableIndices.add(emptyIndex+1);
      if (emptyIndex-1 != lastSwapIndex && emptyIndex%size != 0) availableIndices.add(emptyIndex-1);
      if (emptyIndex+size != lastSwapIndex && emptyIndex~/size != size-1) availableIndices.add(emptyIndex + size);
      if (emptyIndex-size != lastSwapIndex && emptyIndex > size) availableIndices.add(emptyIndex-size);

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
                canUndo = false;
                saveGame();
              });
            }
            updateWidgetList();
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
              showNumbers ? Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tile.empty ? const Color.fromARGB(164, 245, 117, 117) : const Color.fromARGB(101, 255, 255, 255),
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
                )
              ) : SizedBox.shrink(),
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
          Padding(
            padding: EdgeInsets.all(20),
            child: Theme.of(context).brightness == Brightness.light ? Image.asset("icon_cropped.png") : Image.asset("icon_cropped_dark.png"),
          ),
          gameWon ? Text("Congrats !", style: TextStyle(fontSize: 30),) : SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: [
                Icon(Icons.open_with_rounded),
                SizedBox(width: 8),
                Text("Your moves : $moves"),
              ],
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            crossAxisCount: size,
            children: widgets,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded),
                SizedBox(width: 8),
                Text("Minimum moves : $minMoves"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                Text("Show Numbers :"),
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: showNumbers, 
                  onChanged: (value) {
                    setState(() {
                      if (value !=null) {
                        showNumbers = value;
                        updateWidgetList();
                      }
                    });
                  }
                ),
                Spacer(),
                CustomTextButton(
                  enabled: canUndo,
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).primaryColor,
                  text: "UNDO", 
                  width: 100, 
                  action: () {
                    swapTiles(lastSwapIndex);
                    canUndo = false;
                    moves-=2;
                    setState(() {
                      updateWidgetList();
                    });
                  }
                ),
              ],
            ),
          ),
          gameWon ? CustomTextButton(
            textColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundColor: Theme.of(context).primaryColor,
            text: "NEW GAME", 
            width: MediaQuery.of(context).size.width * 0.8, 
            action: () {
              showNewGameDialog(
                context, 
                () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Game(continueGame: false, size: widget.size, shuffleCount: widget.shuffleCount, randomGame: true,)));
                },  
                () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Game(continueGame: false, size: widget.size, shuffleCount: widget.shuffleCount, randomGame: false,)));
                }, 
              ); 
            }
          ) : SizedBox.shrink(),
          SizedBox(height: 20),
          CustomTextButton(
            textColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundColor: Colors.redAccent,
            text: gameWon ? "QUIT" : "SAVE & QUIT", 
            width: MediaQuery.of(context).size.width * 0.8, 
            action: () {
                Navigator.pop(context, gameWon ? false : true);
            }
          ), 
        ],
      )
      : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme.of(context).brightness == Brightness.light ? Image.asset("icon_cropped.png") : Image.asset("icon_cropped_dark.png"),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: LinearProgressIndicator(color: Theme.of(context).primaryColor),
          ),
        ],
      )
    );
  }
}
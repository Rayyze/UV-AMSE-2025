import 'dart:math';
import 'package:flutter/material.dart';

class ExoPage extends StatefulWidget {
  const ExoPage({super.key, required this.title});

  final String title;

  @override
  State<ExoPage> createState() => _ExoPageState();
}

class _ExoPageState extends State<ExoPage> {

  Widget getMenuCard(String title, String description, Widget Function() pageBuilder) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ListTile(
        trailing: Icon(Icons.arrow_forward_ios_rounded,),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(description),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageBuilder()),
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor,)
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.title, style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
      ),
      body: Center(
        child: ListView(
          children: [
            getMenuCard("Ex1", "Random image generator", () => Ex1()),
            getMenuCard("Ex2", "Resize/rotate/scale image", () => Ex2()),
            getMenuCard("Ex4", "Crop image", () => Ex4()),
            getMenuCard("Ex5", "Grid view of an image", () => Ex5()),
            getMenuCard("Ex6", "Grid view with tile swap", () => Ex6()),
          ],
        ),
      )
    );
  }
}

//EX 1
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
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor,)
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Exercice 1", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
      ),
      body: Image.network("https://picsum.photos/1920/1080?random=${Random().nextInt(10000)}")
    );
  }
}

//EX 2
class Ex2 extends StatefulWidget {
  const Ex2({super.key});

  @override
  State<Ex2> createState() => _Ex2State();
}

class _Ex2State extends State<Ex2> {
  double rotateX = 0.0;
  double rotateY = 0.0;
  double rotateZ = 0.0;
  double scale = 1.0;
  bool checkBoxValue = false;
  Image img = Image.network(
    "https://picsum.photos/1920/1080?random=${Random().nextInt(10000)}",
    fit: BoxFit.cover,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor,)),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Exercice 2", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
      ),
      body: Column(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(color: Colors.white),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(rotateY)..rotateX(rotateX) ..rotateZ(rotateZ)..scale(scale),
              child: img,
            ),
          ),
          Text("Rotate X :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: rotateX,
            max: 2*pi,
            onChanged: (double value) {
              setState(() {
                rotateX = value;
              });
            },
          ),
          Text("Rotate Y :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: rotateZ,
            max: 2*pi,
            onChanged: (double value) {
              setState(() {
                rotateZ = value;
              });
            },
          ),
          Row(
            children: [
              Text("Mirror :"),
              Checkbox(
                activeColor: Theme.of(context).primaryColor,
                value: checkBoxValue, 
                onChanged: (value) {
                  setState(() {
                    if (value !=null) {
                      checkBoxValue = value;
                      rotateY = value ? pi : 0.0;
                    }
                  });
                }
              )
            ],
          ),
          Text("Scale :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: scale,
            max: 1.5,
            onChanged: (double value) {
              setState(() {
                scale = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

//EX 4
class Ex4 extends StatefulWidget {
  const Ex4({super.key});

  @override
  State<Ex4> createState() => _Ex4State();
}

class _Ex4State extends State<Ex4> {
  double widthFactor = 0.3;
  double heightFactor = 0.3;
  double alignX = 0.0;
  double alignY = 0.0;
  Image img = Image.network(
    "https://picsum.photos/1920/1080?random=${Random().nextInt(10000)}",
    fit: BoxFit.scaleDown,
  );

  Widget croppedImageTile() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor,)),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Exercice 4", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: croppedImageTile(),
          ),
          Text("Width factor :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: widthFactor,
            max: 1.0,
            onChanged: (double value) {
              setState(() {
                widthFactor = value;
              });
            },
          ),
          Text("Height factor :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: heightFactor,
            max: 1.0,
            onChanged: (double value) {
              setState(() {
                heightFactor = value;
              });
            },
          ),
          Text("X alignement :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: alignX,
            max: 1.0,
            onChanged: (double value) {
              setState(() {
                alignX = value;
              });
            },
          ),
          Text("Y alignement :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: alignY,
            max: 1.0,
            onChanged: (double value) {
              setState(() {
                alignY = value;
              });
            },
          ),
        ],
      )
    );
  }
}

//EX 5
class Ex5 extends StatefulWidget {
  const Ex5({super.key});

  @override
  State<Ex5> createState() => _Ex5State();
}

class _Ex5State extends State<Ex5> {
  static const int imgSize = 1080;
  Image img = Image.network(
    "https://picsum.photos/$imgSize?random=${Random().nextInt(10000)}",
    fit: BoxFit.scaleDown,
  );
  int size = 3;

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

  List<Widget> getTileList() {
    final double tileRatio = 1/size;
    List<Widget> tiles = [];
    for (int i=0; i<size; i++) {
      for (int j=0; j<size; j++) {
        double alignY = (i / (size - 1)) * 2 - 1;
        double alignX = (j / (size - 1)) * 2 - 1;
        
        tiles.add(croppedImageTile(tileRatio, tileRatio, alignX, alignY));
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor,)),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Exercice 5", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              crossAxisCount: size,
              children: getTileList(),
            ),
          ),
          Text("Size :"),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            value: size as double,
            max: 10,
            min: 2,
            divisions: 8,
            onChanged: (double value) {
              setState(() {
                size = value as int;
              });
            },
          ),
          SizedBox(height: 100),
        ]
      )
    );
  }
}


//EXO 6
class Tile {
  Color color = Colors.grey;
  bool empty = false;
  int index = 0;

  Tile(this.index, this.empty) {
    if (empty) {
      color = Colors.white;
    }
  }
}

class Ex6 extends StatefulWidget {
  const Ex6({super.key});

  @override
  State<Ex6> createState() => _Ex6State();
}

class _Ex6State extends State<Ex6> {
  int size = 3;
  int emptyIndex = -1;
  List<Widget> widgets = [];
  List<Tile> tiles = [];

  @override
  void initState() {
    super.initState();
    tiles = getTileList();
    updateWidgetList();
  }

  List<Tile> getTileList() {
    List<Tile> result = [];
    for (int i=0; i<size*size; i++) {
      result.add(Tile(i, false));
    }
    emptyIndex = Random().nextInt(size*size);
    result[emptyIndex] = Tile(result[emptyIndex].index, true);
    return result;
  }

  bool isNextToEmpty(int index) {
    return index == emptyIndex-1 || index == emptyIndex+1 || index == emptyIndex-size || index == emptyIndex+size;
  }

  void swapTiles(int index) {
    if (isNextToEmpty(index)) {
      Tile temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[index];
      tiles[index] = temp;
      emptyIndex = index;
      updateWidgetList();
    }
  }

  void updateWidgetList() {
    List<Widget> result = [];
    for(int i=0; i<tiles.length; i++) {
      Tile tile = tiles[i];
      result.add(
        InkWell(
          onTap: () {
            swapTiles(i);
          },
          child: Stack(
            children: [
              Container(
                color: tile.color,
                child: Padding(
                  padding: EdgeInsets.all(70.0),
                )
              ),
              Text("${tile.index}", style: TextStyle(fontSize: 30),),
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor,)),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Exercice 6", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
      ),
      body: Column(
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
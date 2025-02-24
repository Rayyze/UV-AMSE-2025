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
  double rotateX = 0.0;
  double rotateZ = 0.0;
  double scale = 1.0;
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
          icon: Icon(Icons.arrow_back_ios_rounded)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Exercice 2"),
      ),
      body: Column(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(color: Colors.white),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateX(rotateX) ..rotateZ(rotateZ)..scale(scale),
              child: img,
            ),
          ),
          Text("Rotate X :"),
          Slider(
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
            value: rotateZ,
            max: 2*pi,
            onChanged: (double value) {
              setState(() {
                rotateZ = value;
              });
            },
          ),
          Text("Scale :"),
          Slider(
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
          icon: Icon(Icons.arrow_back_ios_rounded)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Exercice 4"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: croppedImageTile(),
          ),
          Text("Width factor :"),
          Slider(
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

class Ex5 extends StatefulWidget {
  const Ex5({super.key});

  @override
  State<Ex5> createState() => _Ex5State();
}

class _Ex5State extends State<Ex5> {
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
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        crossAxisCount: 3,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("1"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[200],
            child: const Text("2"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[300],
            child: const Text("3"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[400],
            child: const Text("4"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[500],
            child: const Text("5"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[600],
            child: const Text("6"),
          ),
        ],
      )
    );
  }
}
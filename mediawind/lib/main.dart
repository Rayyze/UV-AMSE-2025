import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediawind/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraceWind',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GraceWind'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "";
  List<Item> widgetItems = [];
  String contentType = "";

  @override
  void initState() {
    super.initState();
    title = widget.title;
    widgetItems = [];
    contentType = "loading";
    updateItemList("all");
  }

  Future<void> updateItemList(String type) async {
    List<Item> items = [];
    List<String> urls = [];
    switch (type) {
      case 'all':
        urls.add("https://eldenring.fanapis.com/api/creatures");
        urls.add("https://eldenring.fanapis.com/api/bosses");
    }

    for(String url in urls) {
      bool hasMoreData = true;
      int page = 0;
      int count = 0;
      while (hasMoreData) {
        final response = await http.get(Uri.parse('$url?limit=100&page=$page'));
        if(response.statusCode == 200) {
          final data = jsonDecode(response.body) ?? <String, dynamic>{};
          if (data.containsKey('data')) {
            List elements = data['data'];
            count += elements.length;
            for(Map<String, dynamic> element in elements) {
              items.add(Item.fromJson(element));
            }
            if (count >= (data['total'] ?? 0)) {
              hasMoreData = false;
            } else {
              page++;
            }
          }
        }
      }
    }
    
    setState(() {
      widgetItems = items;
      contentType = "list";
    });
  }

  List<Widget> itemsToWidgets(List<Item> itemList) {
    return itemList.map((elt) {
      return SizedBox(
        height: 80,
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                elt.image,
                fit: BoxFit.fitHeight,
              ),
            ),
            Column(children: [
              Row(children: [
                SizedBox(width: 10),
                Text(elt.name),
                SizedBox(width: 50),
                Icon(Icons.star),
              ]),
              Text(elt.description)
            ])
          ]),
        ),
      );
    }).toList();
  }

  Widget updateMainWidget() {
    switch (contentType) {
      case 'loading':
        return Center(child: CircularProgressIndicator());
      case 'list':
        return ListView(
          shrinkWrap: true,
          children: itemsToWidgets(widgetItems),
        );
      case 'page':
        return Icon(Icons.dangerous);
      default:
        return Icon(Icons.dangerous);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
              ),
              child: Icon(Icons.whatshot, size: 100,)
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: (){
                  setState(() {
                    title = "GraceWind";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.pets),
                title: Text("Creatures"),
                onTap: (){
                  setState(() {
                    title = "Creatures";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text("About"),
                onTap: (){
                  setState(() {
                    title = "About";
                  });
                  Navigator.pop(context);
                },
              )
            ),
          ],
        ),
      ),
      body: updateMainWidget()
    );
  }
}

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GraceWind'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "";
  List<Item> widgetItems = [];
  String contentType = "";
  Map<String, dynamic> itemPageMap = {};

  @override
  void initState() {
    super.initState();
    title = widget.title;
    widgetItems = [];
    contentType = "loading";
    itemPageMap = {};
    updateItemList("all");
  }

  Future<void> updateItemPageMap(Item itemToFetch) async {
    String baseUrl = "https://eldenring.fanapis.com/api/";
    String url = itemToFetch.type;
    String id = itemToFetch.id;
    final response = await http.get(Uri.parse('$baseUrl$url/$id'));
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body) ?? <String, dynamic>{};
      setState(() {
        itemPageMap = data;
        contentType = "page";
      });
    }
  }

  Future<void> updateItemList(String type) async {
    String baseUrl = "https://eldenring.fanapis.com/api/";
    List<Item> items = [];
    List<String> urls = [];
    switch (type) {
      case 'all':
        urls.add("creatures");
        urls.add("bosses");
        urls.add("ammos");
        urls.add("armors");
        urls.add("items");
        urls.add("shields");
        urls.add("weapons");
        urls.add("ashes");
        urls.add("incantations");
        urls.add("sorceries");
        urls.add("spirits");
        urls.add("talismans");
        urls.add("locations");
        urls.add("npcs");
        urls.add("classes");
        break;
      case 'creatures':
        urls.add("creatures");
        urls.add("bosses");
        break;
      case 'equipments':
        urls.add("ammos");
        urls.add("armors");
        urls.add("items");
        urls.add("shields");
        urls.add("weapons");
        break;
      case 'magic':
        urls.add("ashes");
        urls.add("incantations");
        urls.add("sorceries");
        urls.add("spirits");
        urls.add("talismans");
        break;
      case 'locations':
        urls.add("locations");
        break;
      case 'npcs':
        urls.add("npcs");
        break;
      case 'classes':
        urls.add("classes");
        break;
    }

    for(String url in urls) {
      bool hasMoreData = true;
      int page = 0;
      int count = 0;
      while (hasMoreData) {
        final response = await http.get(Uri.parse('$baseUrl$url?limit=100&page=$page'));
        if(response.statusCode == 200) {
          final data = jsonDecode(response.body) ?? <String, dynamic>{};
          if (data.containsKey('data')) {
            List elements = data['data'];
            count += elements.length;
            for(Map<String, dynamic> element in elements) {
              items.add(Item.fromJson(element, url));
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
        height: 100,
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            setState(() {
              updateItemPageMap(elt);
              contentType = "loading";
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 120,
                    height: double.infinity,
                    child: Image.network(
                      elt.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              elt.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Icon(Icons.star_outlined),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        elt.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget itemPageMapToWidget() {
    return Text("Work in progress");
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
        return itemPageMapToWidget();
      default:
        return Icon(Icons.dangerous);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  updateItemList("all");
                  setState(() {
                    contentType = "loading";
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
                  updateItemList("creatures");
                  setState(() {
                    contentType = "loading";
                    title = "Creatures";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.shield),
                title: Text("Equipments"),
                onTap: (){
                  updateItemList("equipments");
                  setState(() {
                    contentType = "loading";
                    title = "Equipments";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.auto_awesome),
                title: Text("Magic"),
                onTap: (){
                  updateItemList("magic");
                  setState(() {
                    contentType = "loading";
                    title = "Magic";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.place),
                title: Text("Locations"),
                onTap: (){
                  updateItemList("locations");
                  setState(() {
                    contentType = "loading";
                    title = "Locations";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.people),
                title: Text("NPCs"),
                onTap: (){
                  updateItemList("npcs");
                  setState(() {
                    contentType = "loading";
                    title = "NPCs";
                  });
                  Navigator.pop(context);
                },
              )
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.workspace_premium),
                title: Text("Classes"),
                onTap: (){
                  updateItemList("classes");
                  setState(() {
                    contentType = "loading";
                    title = "Classes";
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
                    contentType = "about";
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

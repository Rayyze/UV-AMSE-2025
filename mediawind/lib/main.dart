import 'package:flutter/material.dart';
import 'package:mediawind/data_manager.dart';
import 'package:mediawind/item.dart';

DataManager dataManager = DataManager();

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
  final FocusNode _focusNode = FocusNode();
  List<String> categoryList = [];
  List<String> selectedCategoryList = [];

  @override
  void initState() {
    super.initState();
    title = widget.title;
    widgetItems = [];
    contentType = "loading";
    itemPageMap = {};
    updateItemList("all");
    categoryList = dataManager.getCategories();
    selectedCategoryList = [];
  }

  Future<void> updateItemPageMap(Item itemToFetch) async {
    Map<String, dynamic> data = await dataManager.getItemPageMap(itemToFetch);
    setState(() {
      itemPageMap = data;
      contentType = "page";
    });
  }

  Future<void> updateItemList(String type) async {
    List<Item> items = await dataManager.getItemList(type);
    setState(() {
      widgetItems = items;
      contentType = "list";
    });
  }

  void showFilterMenu(BuildContext context, TapDownDetails details, bool animate) {

    showMenu(
      popUpAnimationStyle:  animate ? AnimationStyle() : AnimationStyle(duration: Duration()),
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      items: categoryList.map((category) => PopupMenuItem(
          enabled: false,
          value: category,
          //checked: selectedCategoryList.contains(category),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selectedCategoryList.contains(category)) {
                  selectedCategoryList.remove(category);
                } else {
                  selectedCategoryList.add(category);
                }
              });
              Navigator.pop(context);
              showFilterMenu(context, details, false);
            },
            child: Row(
              children: [
                Icon(
                  selectedCategoryList.contains(category) ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(category, style: const TextStyle(color: Colors.black)),
              ],
            )
          ),
        ),
      ).toList(),
    );
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
          children: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefix: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        widgetItems = dataManager.filter([], value.split(' '));
                        _focusNode.requestFocus();
                      });
                    },
                  ),
                ),
                GestureDetector( //TODO
                  child: Icon(Icons.filter_list_outlined),
                  onTapDown: (details) => showFilterMenu(context, details, true),
                ),
              ],
            ),
          ),
          ...itemsToWidgets(widgetItems),]
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

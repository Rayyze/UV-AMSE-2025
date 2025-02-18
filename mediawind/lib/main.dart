import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediawind/data_manager.dart';
import 'package:mediawind/item.dart';

DataManager dataManager = DataManager();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromARGB(255, 20, 20, 20),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightGrey =Color.fromARGB(255, 29, 29, 29);
    const Color darkGrey =Color.fromARGB(255, 20, 20, 20);
    return MaterialApp(
      title: 'GraceWind',
      theme: ThemeData(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        colorScheme: ColorScheme.dark(
          primary: lightGrey,
          onPrimary: darkGrey,
          
          secondary: Colors.amber,
          onSecondary: Colors.black,
          
          surface: lightGrey,
          onSurface: Colors.white,
          
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          color: darkGrey,
          shadowColor: Colors.black,
          elevation: 4,
        ),
        iconTheme: IconThemeData(
          color: Colors.amber,
        ),
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: Colors.amber,
          
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.amber, width: 2),
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.amber,
          ),
          backgroundColor: darkGrey,
        ),
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
  String previousTitle = "";
  List<Item> widgetItems = [];
  String contentType = "";
  Map<String, dynamic> itemPageMap = {};
  final FocusNode _focusNode = FocusNode();
  List<String> categoryList = [];
  List<String> selectedCategoryList = [];
  String keywords = "";
  Map<String, dynamic> aboutMap = {};
  Widget mainWidgetIcon = SizedBox(
    height: 40,
    child: Image.asset("assets/icon.png", fit: BoxFit.scaleDown),
  );

  @override
  void initState() {
    super.initState();
    title = widget.title;
    widgetItems = [];
    contentType = "loading";
    itemPageMap = {};
    updateItemList("all");
    categoryList = dataManager.getCategories("all");
    selectedCategoryList = dataManager.getCategories("all");
  }

  Future<void> updateItemPageMap(Item itemToFetch) async {
    Map<String, dynamic> data = await dataManager.getItemPageMap(itemToFetch);
    setState(() {
      itemPageMap = data;
      contentType = "page";
      previousTitle = title;
      title = itemPageMap["name"];
    });
  }

  Future<void> updateItemList(String type) async {
    await dataManager.getItemList(type);
    List<Item> items = dataManager.filter(selectedCategoryList, keywords.split(' '));
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
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selectedCategoryList.contains(category)) {
                  selectedCategoryList.remove(category);
                } else {
                  selectedCategoryList.add(category);
                }
                widgetItems = dataManager.filter(selectedCategoryList, keywords.split(' '));
              });
              Navigator.pop(context);
              showFilterMenu(context, details, false);
            },
            child: Row(
              children: [
                Icon(
                  selectedCategoryList.contains(category) ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(category, style: const TextStyle(color: Colors.white)),
                ),
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
        height: 105,
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
                    child: dataManager.isNetworkUrl(elt.image) ? Image.network(
                      elt.image,
                      fit: BoxFit.cover,
                    ) : Image.asset(
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
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          IconButton(
                            onPressed:() {
                              dataManager.updateFavorites(elt.id);
                              updateItemList("current");
                            },
                            icon: Icon(elt.liked ? Icons.favorite_outlined : Icons.favorite_border_outlined, color: elt.liked ? Colors.red : Colors.amber,),
                          ),
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

  String splitCamelCase(String text) {
  return text.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
    return "${match.group(1)} ${match.group(2)}";
  });
}

  Widget itemFieldToWidget(MapEntry<String, dynamic> entry) {
    String key = entry.key;
    dynamic value = entry.value;

    if (value == null || key == "name" || key == "image" || key == "id") {
      return SizedBox.shrink();
    }

    Widget valueWidget = Text("");

    if (value is Map) {
      valueWidget = Column(
        children: value.entries.map((valueEntry) {
          String valueKey = valueEntry.key.toString();
          String valueValue = valueEntry.value.toString();
          return Text("$valueKey : $valueValue");
        }).toList()
      );
    } else if (value is List) {
      valueWidget = Column(
        children: value.map((elt) {
          if (elt is Map) {
            String name = elt.values.first.toString();
            String amount = elt.values.last.toString();
            return Text("$name : $amount");
          }
          return Text(elt.toString());
        }).toList(),
      );
    } else {
      valueWidget = Text(value.toString());
    }

    return Column(
      children: [
        Text(splitCamelCase(key).toUpperCase(), style: TextStyle(color: Colors.amber)),
        SizedBox(height: 10),
        valueWidget,
        SizedBox(height: 20),
      ],
    );
  }

  Widget itemPageMapToWidget() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    contentType = "list";
                    title = previousTitle;
                  });
                },
                icon: Icon(Icons.arrow_back_outlined),
              ),
              Text(previousTitle),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                dataManager.isNetworkUrl(itemPageMap["image"]) ? Image.network(itemPageMap["image"]) : Image.asset(itemPageMap["image"]),
                ...itemPageMap.entries.map((entry) {
                  return itemFieldToWidget(entry);
                }),
              ],
            )
          )
        ],
      )
    );
  }

  Future<void> updateAboutInfo() async {
    aboutMap = await dataManager.getAboutInfo();
    setState(() {
      contentType = "about";
    });
  }

  Widget updateMainWidget() {
    switch (contentType) {
      case 'loading':
        return Center(child: CircularProgressIndicator(color: Colors.amber));
      case 'list':
        return ListView(
          shrinkWrap: true,
          children: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: keywords),
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefix: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        keywords = value;
                        widgetItems = dataManager.filter(selectedCategoryList, keywords.split(' '));
                        _focusNode.requestFocus();
                      });
                    },
                  ),
                ),
                GestureDetector(
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
      case 'about':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: aboutMap.entries.map((entry) {
              String key = entry.key;
              String value = entry.value.toString();
              
              if (key == "title" || key == "conclusion") {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (key == "title") ? Text(value, style: TextStyle(color: Colors.amber, fontSize: 30),) : Text(value),
                    SizedBox(height: 10),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(key, style: TextStyle(color: Colors.amber, fontSize: 20)),
                    SizedBox(height: 8),
                    Text(value),
                    SizedBox(height: 10),
                  ],
                );
              }
            }).toList(),
          ),
        );
      default:
        return Icon(Icons.dangerous);
    }
  }

  Widget getMenuCard(String pageTitle, String itemListType, IconData iconData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ListTile(
        leading: Icon(iconData, color: Colors.amber,),
        title: Text(pageTitle, style: TextStyle(color: Colors.amber),),
        onTap: (){
          updateItemList(itemListType);
          setState(() {
            contentType = "loading";
            mainWidgetIcon = (pageTitle == "Home") ? SizedBox(
                height: 40,
                child: Image.asset("assets/icon.png", fit: BoxFit.scaleDown),
              ) : Icon(iconData);
            title = (pageTitle == "Home") ? "GraceWind" : pageTitle;
            keywords = "";
            categoryList = dataManager.getCategories(itemListType);
            selectedCategoryList = dataManager.getCategories(itemListType);
          });
          Navigator.pop(context);
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            mainWidgetIcon,
            SizedBox(width: 20.0),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ) 
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 250,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child:Image.asset("assets/icon.png"),
                    ),
                    SizedBox(height: 10),
                    Text("GraceWind", style: TextStyle(color: Colors.amber, fontSize: 30)),
                    SizedBox(height: 10),
                  ],
                ) 
              )
            ),
            getMenuCard("Home", "all", Icons.home),
            getMenuCard("Favorites", "liked", Icons.favorite_outlined),
            getMenuCard("Creatures", "creatures", Icons.pets),
            getMenuCard("Equipments", "equipments", Icons.shield),
            getMenuCard("Magic", "magic", Icons.auto_awesome),
            getMenuCard("Locations", "locations", Icons.place),
            getMenuCard("NPCs", "npcs", Icons.people),
            getMenuCard("Classes", "classes", Icons.workspace_premium),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                leading: Icon(Icons.help, color: Colors.amber,),
                title: Text("About", style: TextStyle(color: Colors.amber),),
                onTap: (){
                  setState(() {
                    updateAboutInfo();
                    contentType = "loading";
                    mainWidgetIcon = Icon(Icons.help, color: Colors.amber);
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

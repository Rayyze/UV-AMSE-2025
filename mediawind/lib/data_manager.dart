import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mediawind/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  List<Item> items = [];
  String currentType = "";
  Map<String, dynamic> itemPageMap = {};

  String baseUrl = "https://eldenring.fanapis.com/api/";
  List<String> likedItems = [];
  bool favoritesPulled = false;

  DataManager() {
    pullFavorites();
  }

  Future<Map<String, dynamic>> getItemPageMap(Item itemToFetch) async {
    items = [];
    String url = itemToFetch.type;
    String id = itemToFetch.id;
    final response = await http.get(Uri.parse('$baseUrl$url/$id'));
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body) ?? <String, dynamic>{};
      itemPageMap = data;
      return data;
    }

    itemPageMap = {};
    return {};
  }

  List<String> getCategories(String type) {
    Map<String, List<String>> categoryMap = {
      'all': [
        "creatures", "bosses", "ammos", "armors", "items", "shields", "weapons",
        "ashes", "incantations", "sorceries", "spirits", "talismans", "locations",
        "npcs", "classes"
      ],
      'creatures': ["creatures", "bosses"],
      'equipments': ["ammos", "armors", "items", "shields", "weapons"],
      'magic': ["ashes", "incantations", "sorceries", "spirits", "talismans"],
      'locations': ["locations"],
      'npcs': ["npcs"],
      'classes': ["classes"]
    };

    return categoryMap[type] ?? [];
  }

  Future<List<Item>> getItemList(String type) async {
    if (currentType == type || type == "current") {
      return items;
    } else {
      return await fetchItemList(type);
    }
  }

  Future<List<Item>> fetchItemList(String type) async {
    while(!favoritesPulled) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    items = [];
    List<String> urls = getCategories(type);

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
              Item tempItem = Item.fromJson(element, url, false);
              tempItem.liked = likedItems.contains(tempItem.id);
              items.add(tempItem);
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
    
    return items;
  }

  List<Item> filter(List<String> types, List<String> keywords) {
    List<Item> filteredItems = [];
    bool typeMatch = false;
    bool keywordMatch = false;
    for(Item item in items) {
      keywordMatch = false;
      typeMatch = false;
      for(String type in types) {
        if (item.type == type) {
          typeMatch = true;
        }
      }
      for (String keyword in keywords) {
        if (item.name.toLowerCase().contains(keyword.toLowerCase()) || item.description.toLowerCase().contains(keyword.toLowerCase())) {
          keywordMatch = true;
        }
      }
      if (keywordMatch && typeMatch) {
        filteredItems.add(item);
      }
    }
    return filteredItems;
  }

  Future<void> pullFavorites() async { // TODO DartError: FormatException: SyntaxError: Unexpected end of JSON input
    final prefs = await SharedPreferences.getInstance();
    String content = prefs.getString('favorites') ?? "";
    final data = jsonDecode(content) ?? <String, dynamic>{};
    likedItems = data['data'];
    favoritesPulled = true;
  }

  Future<void> pushFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    var data = {'data': likedItems};
    String content = jsonEncode(data);
    await prefs.setString('jsonData', content);
  }

  void updateFavorites(String itemId) {
    if (likedItems.contains(itemId)) {
      likedItems.remove(itemId);
    } else {
      likedItems.add(itemId);
    }
    for (Item item in items) {
      if (item.id == itemId) {
        print(item.name);
        item.liked = !item.liked;
      }
    }
    pushFavorites();
  }
}
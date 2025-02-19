import 'dart:convert';
import 'package:flutter/services.dart';
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

  bool isNetworkUrl(String path) {
    return path.startsWith('http');
  }

  Future<Map<String, dynamic>> getItemPageMap(Item? itemToFetch) async {
    if (itemToFetch == null || itemPageMap["liked"] == itemToFetch.id) {
      return itemPageMap;
    }
    String url = itemToFetch.type;
    String id = itemToFetch.id;
    final response = await http.get(Uri.parse('$baseUrl$url/$id'));
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body) ?? <String, dynamic>{};
      itemPageMap = data["data"];
      itemPageMap["image"] = itemPageMap["image"] ?? "assets/default_image.jpg";
      itemPageMap["description"] = itemPageMap["description"] ?? "No description";
      itemPageMap["liked"] = itemToFetch.liked;
      return itemPageMap;
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
      'liked': [
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
    if (type != "liked" && (currentType == type || type == "current")) {
      return items;
    } else {
      if (type == "liked") {
        items = getLikedIn(await fetchItemList("liked"));
        return items;
      } else {
        return await fetchItemList(type);
      }
    }
  }

  List<Item> getLikedIn(List<Item> input) {
    List<Item> output = [];
    for (Item item in input) {
      if (item.liked) {
        output.add(item);
      }
    }
    return output;
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
    
    currentType = type;
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

  Future<void> pullFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    String content = prefs.getString('favorites') ?? '{"data": []}';
    final data = jsonDecode(content);
    likedItems = data['data'].cast<String>();
    favoritesPulled = true;
  }

  Future<void> pushFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    var data = {'data': likedItems};
    String content = jsonEncode(data);
    await prefs.setString('favorites', content);
  }

  void updateFavorites(String itemId) {
    if (likedItems.contains(itemId)) {
      likedItems.remove(itemId);
    } else {
      likedItems.add(itemId);
    }
    for (Item item in items) {
      if (item.id == itemId) {
        item.liked = !item.liked;
      }
    }
    if (itemPageMap["id"] == itemId) {
      itemPageMap["liked"] = !itemPageMap["liked"];
    }
    pushFavorites();
  }

  Future<Map<String, dynamic>> getAboutInfo() async {
  String jsonString = await rootBundle.loadString('assets/about.json');
  return jsonDecode(jsonString);
  }
}
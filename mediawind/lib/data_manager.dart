import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediawind/item.dart';

class DataManager {
  List<Item> items = [];
  Map<String, dynamic> itemPageMap = {};
  String baseUrl = "https://eldenring.fanapis.com/api/";

  DataManager();

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
    
    return items;
  }

  List<Item> filter(List<String> types, List<String> keywords) {
    List<Item> filteredItems = [];
    bool typeMatch = false;
    bool keywordMatch = false;
    for(Item item in items) {
      typeMatch = false;
      keywordMatch = false;
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
}
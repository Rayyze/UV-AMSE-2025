import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediawind/item.dart';

class DataManager {
  List<Item> widgetItems = [];
  Map<String, dynamic> itemPageMap = {};
  String baseUrl = "https://eldenring.fanapis.com/api/";

  DataManager();

  Future<Map<String, dynamic>> getItemPageMap(Item itemToFetch) async {
    String url = itemToFetch.type;
    String id = itemToFetch.id;
    final response = await http.get(Uri.parse('$baseUrl$url/$id'));
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body) ?? <String, dynamic>{};
      return data;
    }

    return {};
  }

  Future<List<Item>> getItemList(String type) async {
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
    
    return items;
  }
}
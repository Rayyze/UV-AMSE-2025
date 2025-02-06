
class Item {
  final String id;
  final String description;
  final String name;
  final String image;
  final String type;

  Item({
    required this.id,
    required this.description,
    required this.name,
    required this.image,
    required this.type,
  });

  factory Item.fromJson(Map<String, dynamic> json, String type) {
    return Item(
      id: json['id'] as String,
      description: (json['description'] ?? "") as String,
      name: json['name'] as String,
      image: (json['image'] ?? "../assets/default_image.jpg") as String,
      type: type,
    );
  }
}


class Item {
  final String id;
  final String description;
  final String name;
  final String image;

  Item({
    required this.id,
    required this.description,
    required this.name,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      description: (json['description'] ?? "") as String,
      name: json['name'] as String,
      image: (json['image'] ?? "../assets/default_image.jpg") as String,
    );
  }
}
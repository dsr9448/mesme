class GroceryItem {
  final int id;
  final String name;
  final String price;
  final String quantity;
  final String unit;
  final String imageUrl;
  final String description;
  final int categoryId;

  GroceryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.description,
    required this.categoryId,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      unit: json['unit'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      categoryId: json['categoryId'],
    );
  }
}
class Grocery {
  final int id;
  final String name;
  final String location;
  final List<GroceryItem> groceryItem;

  Grocery({
    required this.id,
    required this.name,
    required this.location,
    required this.groceryItem,
  });

  factory Grocery.fromJson(Map<String, dynamic> json) {
    var gitems = json['items'] as List;
    List<GroceryItem> groceryItem =
        gitems.map((i) => GroceryItem.fromJson(i)).toList();
    return Grocery(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        groceryItem: groceryItem,
        );
  }
}

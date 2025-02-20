class GroceryItem {
  final int id;
  final String name;
  final String price;
  final String quantity;
  final String unit;
  final String imageUrl;
  final String description;
  final int categoryId;
  final String category;

  GroceryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.description,
    required this.categoryId,
    required this.category,
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
      category: json['category'],
    );
  }
}

class Grocery {
  final int id;
  final String name;
  final String ShopName;
  final String location;
  final String phoneNumber;
  final String coordinates;
  final bool isOnline;
  final String time;
  final String description;
  final String area;
  final List<GroceryItem> groceryItem;


  Grocery({
    required this.id,
    required this.name,
    required this.ShopName,
    required this.location,
    required this.phoneNumber,
    required this.coordinates,
    required this.isOnline,
    required this.groceryItem,
    required this.time,
    required this.description,
    required this.area,
  });

  factory Grocery.fromJson(Map<String, dynamic> json) {
    var gitems = json['items'] as List;
    List<GroceryItem> groceryItem =
        gitems.map((i) => GroceryItem.fromJson(i)).toList();
    return Grocery(
      id: json['id'],
      name: json['name'],
      ShopName: json['ShopName'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      coordinates: json['coordinates'],
      isOnline: json['isOnline'],
      time: json['time'],
      description: json['description'],
      area: json['area'],
      groceryItem: groceryItem,
    );
  }
}

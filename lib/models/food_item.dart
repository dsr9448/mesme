// restaurant.dart

class FoodItem {
  final int id;
  final String foodName;
  final String foodPhoto;
  final String foodDescription;
  final String Quantity;
  final String Unit;
  final String price;
  final String vegOrNonVeg;
  final String rating;
  final String category;
  final int restaurantId;
  final int totalCount;
  final int stock;

  FoodItem({
    required this.id,
    required this.foodName,
    required this.foodPhoto,
    required this.foodDescription,
    required this.Quantity,
    required this.Unit,
    required this.price,
    required this.vegOrNonVeg,
    required this.rating,
    required this.category,
    required this.restaurantId,
    required this.totalCount,
    required this.stock,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      foodName: json['foodName'] ?? '',
      foodPhoto: json['foodPhoto'] ?? '',
      foodDescription: json['foodDescription'] ?? '',
      Quantity: json['Quantity'] ?? '',
      Unit: json['Unit'] ?? '',
      price: json['price'] ?? '',
      vegOrNonVeg: json['vegOrNonVeg'] ?? '',
      rating: json['rating'] ?? '',
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      totalCount: json['totalCount'] ?? '',
    );
  }
}

class Restaurant {
  final String rid;
  final int id;
  final String name;
  final String location;
  final String phoneNumber;
  final String coordinates;
  final bool isOnline;
  final String time;
  final String rtime;
  final String description;
  final String area;
  final String style;
  final String rphoto;
  final String rating;
  final int totalOrders;
  final List<FoodItem> foodItems;

  Restaurant(
      {required this.rid,
      required this.id,
      required this.name,
      required this.location,
      required this.phoneNumber,
      required this.coordinates,
      required this.isOnline,
      required this.time,
      required this.rtime,
      required this.description,
      required this.area,
      required this.style,
      required this.rphoto,
      required this.rating,
      required this.foodItems,
      required this.totalOrders});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var foodItemsList = json['foodItems'] as List;
    List<FoodItem> foodItems =
        foodItemsList.map((i) => FoodItem.fromJson(i)).toList();

    return Restaurant(
      rid: json['rid'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      coordinates: json['coordinates'] ?? '',
      isOnline: json['isOnline'] ?? '',
      time: json['time'] ?? '',
      rtime: json['rtime'] ?? '',
      description: json['description'] ?? '',
      area: json['area'] ?? '',
      style: json['style'] ?? '',
      rphoto: json['rphoto'] ?? '',
      rating: json['rating'].toString() ?? '',
      totalOrders: json['totalOrders'] ?? '',
      foodItems: foodItems,
    );
  }
}

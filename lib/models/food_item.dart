// restaurant.dart

class FoodItem {
  final int id;
  final String foodName;
  final String foodPhoto;
  final String foodDescription;
  final String price;
  final String vegOrNonVeg;
  final String rating;
  final int restaurantId;

  FoodItem({
    required this.id,
    required this.foodName,
    required this.foodPhoto,
    required this.foodDescription,
    required this.price,
    required this.vegOrNonVeg,
    required this.rating,
    required this.restaurantId,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      foodName: json['foodName'],
      foodPhoto: json['foodPhoto'],
      foodDescription: json['foodDescription'],
      price: json['price'],
      vegOrNonVeg: json['vegOrNonVeg'],
      rating: json['rating'],
      restaurantId: json['restaurantId'],
    );
  }
}

class Restaurant {
  final int id;
  final String name;
  final String location;
  final String phoneNumber;
  final bool isOnline;
  final List<FoodItem> foodItems;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.phoneNumber,
    required this.isOnline,
    required this.foodItems,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var foodItemsList = json['foodItems'] as List;
    List<FoodItem> foodItems =
        foodItemsList.map((i) => FoodItem.fromJson(i)).toList();

    return Restaurant(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      isOnline: json['isOnline'],
      foodItems: foodItems,
    );
  }
}

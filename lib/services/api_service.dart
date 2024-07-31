import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<BannerImage> _bannerImages = [];

  List<Restaurant> get restaurants => _restaurants;
  List<BannerImage> get bannerImages => _bannerImages;

  ApiService() {
    fetchData();
  }

  Future<void> fetchData() async {
    final url = 'https://mesme.in/admin/api/Food/get.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Debugging line
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          _restaurants = List<Restaurant>.from(
              data['restaurants'].map((item) => Restaurant.fromJson(item)));
          _bannerImages = List<BannerImage>.from(
              data['bannerImages'].map((item) => BannerImage.fromJson(item)));
          notifyListeners();
        } else {
          throw Exception('Invalid JSON structure');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }
}

class BannerImage {
  final String imgUrl;

  BannerImage({required this.imgUrl});

  factory BannerImage.fromJson(Map<String, dynamic> json) {
    return BannerImage(
      imgUrl: json['imgUrl'],
    );
  }
}

class FoodItem {
  final String id;
  final String foodName;
  final String foodPhoto;
  final String foodDescription;
  final String price;
  final String vegOrNonVeg;
  final String rating;
  final String restaurantId;

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
  final String id;
  final String name;
  final String location;
  final String phoneNumber;
  final String isOnline;
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
    return Restaurant(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      isOnline: json['isOnline'],
      foodItems: List<FoodItem>.from(
          json['foodItems'].map((item) => FoodItem.fromJson(item))),
    );
  }
}

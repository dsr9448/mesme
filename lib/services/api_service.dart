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
  Future<void> createOrder(String userId, String status, String deliveryAddress,
      double totalPrice, List<Map<String, dynamic>> items) async {
    final url = 'https://mesme.in/admin/api/FoodOrders/create.php';

    // Prepare the data
    final requestData = {
      'userId': userId,
      'partnerId': '',
      'status': status,
      'deliveryAddress': deliveryAddress,
      'totalPrice': totalPrice.toString(),
      'items': items,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      // Check the response status
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          print('Order created successfully: ${responseData['orderId']}');
          // Handle success, e.g., navigate to a confirmation page or show a success message
        } else {
          print('Failed to create order: ${responseData['message']}');
          // Handle failure, e.g., show an error message
        }
      } else {
        print('Server error: ${response.statusCode}');
        // Handle server error
      }
    } catch (error) {
      print('Error: $error');
      // Handle network or parsing error
    }
  }

  Future<void> updateFoodOrder(String orderId, String status) async {
    // API endpoint URL

    // Data to be sent as JSON
    Map<String, dynamic> requestData = {
      'orderId': orderId,
      'status': status,
      'isActive': 1,
    };

    try {
      // Sending the request to the server
      final response = await http.post(
        Uri.parse('https://mesme.in/admin/api/FoodOrders/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      // Checking the response status code
      if (response.statusCode == 200) {
        // If the server returns a response with a 200 status code, parse the JSON
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        notifyListeners();
        // Handle the response from the server
        if (responseBody['error'] != null) {
          // Handle error case
          print('Error: ${responseBody['error']}');
        } else {
          // Success case
          print('Success: ${responseBody['message']}');
        }
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Request error: $e');
    }
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

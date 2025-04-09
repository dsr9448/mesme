import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<BannerImage> _bannerImages = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _cache = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);
  DateTime? _lastFetchTime;
  static const Duration _minimumFetchInterval = Duration(minutes: 1);
  static const Duration _connectionTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 15);
  Map<String, Future<dynamic>> _pendingRequests = {};

  List<Restaurant> get restaurants => _restaurants;
  List<BannerImage> get bannerImages => _bannerImages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ApiService() {
    // Don't fetch immediately on construction
    // fetchData();
  }

  Future<dynamic> _deduplicateRequest(
      String key, Future<dynamic> Function() request) async {
    if (_pendingRequests.containsKey(key)) {
      return _pendingRequests[key];
    }

    final future = request();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      _pendingRequests.remove(key);
      return result;
    } catch (e) {
      _pendingRequests.remove(key);
      rethrow;
    }
  }

  Future<void> fetchData({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _minimumFetchInterval) {
      return;
    }

    return _deduplicateRequest('fetchData', () async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final url = 'https://mesme.inkaradigital.com/admin/api/Food/get.php';
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
          },
        ).timeout(_connectionTimeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is Map<String, dynamic>) {
            _restaurants = List<Restaurant>.from(
                data['restaurants'].map((item) => Restaurant.fromJson(item)));
            _bannerImages = List<BannerImage>.from(
                data['bannerImages'].map((item) => BannerImage.fromJson(item)));
            _lastFetchTime = DateTime.now();
            notifyListeners();
          } else {
            throw Exception('Invalid JSON structure');
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } on SocketException catch (e) {
        _error = 'Connection error: Please check your internet connection';
        print('Socket Exception: $e');
      } on TimeoutException catch (e) {
        _error = 'Connection timed out: Please try again';
        print('Timeout Exception: $e');
      } catch (e) {
        _error = 'An error occurred: $e';
        print('General Exception: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Cache frequently accessed data
  Future<dynamic> _getCachedOrFetch(
      String key, Future<dynamic> Function() fetchData) async {
    if (_cache.containsKey(key) &&
        DateTime.now().difference(_cache[key]['timestamp']) < _cacheExpiry) {
      return _cache[key]['data'];
    }

    final data = await fetchData();
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
    return data;
  }

  // Optimize order creation with retry logic and better error handling
  Future<Map<String, dynamic>> createOrder(
      String userId,
      String rid,
      String status,
      String deliveryAddress,
      double totalPrice,
      List<Map<String, dynamic>> items) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Format items to match API expectations
        final formattedItems = items
            .map((item) => {
                  'category': item['category'] ?? '',
                  'itemName': item['itemName'] ?? '',
                  'qty': item['qty'] ?? 1,
                  'price': item['price']?.toString() ?? '0',
                })
            .toList();

        final response = await http
            .post(
              Uri.parse(
                  'https://mesme.inkaradigital.com/admin/api/FoodOrders/create.php'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Connection': 'keep-alive',
              },
              body: jsonEncode({
                'userId': userId,
                'partnerId': rid,
                'status': status,
                'deliveryAddress': deliveryAddress,
                'totalPrice': totalPrice.toString(),
                'items': formattedItems,
              }),
            )
            .timeout(_connectionTimeout);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (responseData['success'] == true) {
            return {
              'success': true,
              'data': responseData,
              'orderId': responseData['orderId']
            };
          } else {
            return {
              'success': false,
              'error': responseData['message'] ?? 'Failed to create order'
            };
          }
        } else {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}'
          };
        }
      } on SocketException catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          return {
            'success': false,
            'error': 'Connection error: Please check your internet connection'
          };
        }
        await Future.delayed(Duration(seconds: retryCount));
      } on TimeoutException catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          return {
            'success': false,
            'error': 'Connection timed out: Please try again'
          };
        }
        await Future.delayed(Duration(seconds: retryCount));
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          return {'success': false, 'error': 'An error occurred: $e'};
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return {'success': false, 'error': 'Max retries exceeded'};
  }

  Future<void> updateFoodOrder(String orderId, String status) async {
    // API endpoint URL

    // Data to be sent as JSON
    Map<String, dynamic> requestData = {
      'orderId': orderId,
      'status': status,
      'isActive': 0,
    };

    try {
      // Sending the request to the server
      final response = await http.post(
        Uri.parse(
            'https://mesme.inkaradigital.com/admin/api/FoodOrders/update.php'),
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

  Future<void> updateOrderRating(String orderId, String rating) async {
    // Data to be sent as JSON
    Map<String, dynamic> requestData = {
      'orderId': orderId.toString(), // Ensure orderId is a string
      'rating': rating.toString(), // Ensure rating is a string
    };

    try {
      // Sending the request to the server
      final response = await http.post(
        Uri.parse(
            'https://mesme.inkaradigital.com/admin/api/FoodOrders/rating.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

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

  Future<void> updatePayment(String orderId, String status) async {
    // Data to be sent as JSON
    Map<String, dynamic> requestData = {
      'orderId': orderId,
      'rating': status, // Change 'status' to 'rating'
    };

    try {
      // Sending the request to the server
      final response = await http.post(
        Uri.parse(
            'https://mesme.inkaradigital.com/admin/api/FoodPayments/update.php'),
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

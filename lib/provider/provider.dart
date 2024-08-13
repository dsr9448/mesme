import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/models/food_item.dart';
import 'package:mesme/models/grocery_model.dart';
import 'package:mesme/models/ordermodel.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Auth

class FoodProvider with ChangeNotifier {
  List<Restaurant> restaurants = [];
  List<String> bannerImages = [];
  List<Grocery> groceries = [];
  List<Order> orders = [];
  User? user = FirebaseAuth.instance.currentUser;
  UserModel? userData;
  Map<int, List<GroceryItem>> groceryCategoriesMap = {};
  bool isLoading = true;

  FoodProvider() {
    fetchRestaurants();
    fetchGrocery();
    fetchUserData();
    fetchSavedAddress();
    fetchOrders();
  }

  Future<void> fetchRestaurants() async {
    final response =
        await http.get(Uri.parse('https://mesme.in/admin/api/Food/get.php'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      restaurants = (jsonData['restaurants'] as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
      bannerImages = List<String>.from(jsonData['bannerImages']);
      notifyListeners(); // Notify listeners to update UI
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<void> fetchGrocery() async {
    final response = await http
        .get(Uri.parse('https://mesme.in/admin/api/Food/getGrocery.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<Grocery> loadedGroceries = [];
      final Map<int, List<GroceryItem>> loadedCategoriesMap = {};

      // Parse categories
      for (var categoryJson in data['categories']) {
        final category = Grocery.fromJson(categoryJson);
        loadedGroceries.add(category);
        loadedCategoriesMap[category.id] = [];

        // Parse items for each category
        for (var itemJson in categoryJson['items']) {
          final item = GroceryItem.fromJson(itemJson);
          loadedCategoriesMap[category.id]?.add(item);
        }
      }

      groceries = loadedGroceries;
      groceryCategoriesMap = loadedCategoriesMap;
      notifyListeners(); // Notify listeners to update UI
    } else {
      throw Exception('Failed to load groceries');
    }
  }

  Future<void> fetchUserData() async {
    try {
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      var url = 'https://mesme.in/admin/api/users/get.php?id=${user!.uid}';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData = UserModel.fromMap(data);
        fetchSavedAddress();
        notifyListeners(); // Notify listeners to update UI
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // Notify listeners to update UI
    }
  }

  Future<String?> fetchSavedAddress() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated');
      }
      var url = 'https://mesme.in/admin/api/users/get.php?id=${user.uid}';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);

        notifyListeners(); // Notify listeners when the address is updated
        return userData['address'] ?? ''; // Return the saved address
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching saved address: $e");
      return null; // Return null in case of error
    }
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(
        'https://mesme.in/admin/api/FoodOrders/get.php?userId=${user!.uid}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> orderList = data['orders'];
        orders = orderList.map((orderData) {
          return Order.fromMap(orderData);
        }).toList();
        notifyListeners(); // Notify listeners to update UI
      } else {
        throw Exception('Failed to load orders: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }
}

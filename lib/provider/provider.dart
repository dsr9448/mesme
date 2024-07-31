import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/models/food_item.dart';
import 'package:mesme/models/grocery_model.dart';

class FoodProvider with ChangeNotifier {
  List<Restaurant> restaurants = [];
  List<String> bannerImages = [];
 List<Grocery> groceries = [];
  Map<int, List<GroceryItem>> groceryCategoriesMap = {};
  bool isLoading = true;

  FoodProvider() {
    fetchRestaurants();
   fetchGrocery(); 
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
      isLoading = false;
      notifyListeners();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
  Future<void> fetchGrocery() async {
  final response = await http.get(Uri.parse('https://mesme.in/admin/api/Food/getGrocery.php'));

    
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
      isLoading = false;
      notifyListeners();
    } else {
      throw Exception('Failed to load groceries');
    }
  }
}
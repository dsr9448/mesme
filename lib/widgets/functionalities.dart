import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';

class FoodFunction {
  static ValueNotifier<int> cartItemCountNotifier = ValueNotifier<int>(0);

  static Future<void> addToCart(
      String name,
      double price,
      int quantity,
      String imageUrl,
      String restaurantName,
      String location,
      String coordinates,
      String distance,
      String rid,
      String menuType,
      String category, // Add category parameter
      BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    Set<String> existingCategories = {};
    Set<String> existingrestaurantName = {};

    // Check existing cart items for categories
    for (String itemJson in cartItems) {
      Map<String, dynamic> item = jsonDecode(itemJson);
      // existingCategories.add(item['category']);
      existingrestaurantName.add(item['restaurantName']);
    }

    // Prevent adding items from different categories
    // if (existingCategories.isNotEmpty &&
    //     !existingCategories.contains(category)) {
    //   QuickAlert.show(
    //     context: context,
    //     type: QuickAlertType.confirm,
    //     title: 'Replace cart item?',
    //     text:
    //         'Your cart contains items from ${existingCategories.first} . Do you want to discard the selection & add items from ${category == "Grocery" ? "Sweets" : "Food"}?',
    //     confirmBtnText: 'Yes',
    //     cancelBtnText: 'No',
    //     confirmBtnColor: Colors.orange.shade700,
    //     onConfirmBtnTap: () async {
    //       SharedPreferences prefs = await SharedPreferences.getInstance();
    //       await prefs.remove('cartItems');
    //       FoodFunction.updateCartItemCount(0);

    //       // Clear the cart first
    //       cartItems.clear();

    //       // Now add the new item to the cart
    //       Map<String, dynamic> item = {
    //         'name': name,
    //         'price': price,
    //         'quantity': quantity,
    //         'imageUrl': imageUrl,
    //         'restaurantName': restaurantName,
    //         'location': location,
    //         'category': category, // Add category to the item
    //         'rid': rid,
    //         'menuType': menuType,
    //       };

    //       cartItems.add(jsonEncode(item)); // Add JSON encoded string
    //       await prefs.setStringList('cartItems', cartItems);
    //       int newCount = cartItems.length;
    //       await FoodFunction.updateCartItemCount(newCount);

    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text('Added $quantity $name to cart'),
    //           backgroundColor: Colors.orange.shade700,
    //           closeIconColor: Colors.white,
    //           duration: const Duration(seconds: 2),
    //           showCloseIcon: true,
    //           behavior: SnackBarBehavior.floating,
    //         ),
    //       );
    //       Navigator.of(context)
    //           .pop(); // Navigate back after adding the new items
    //     },
    //   );
    //   return;
    // }
    if (existingrestaurantName.isNotEmpty &&
        !existingrestaurantName.contains(restaurantName)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: 'Replace cart item?',
        text:
            'Your cart contains dishes from ${existingrestaurantName.first} . Do you want to discard the selection & add dishes from ${restaurantName}?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: Colors.orange.shade700,
        onConfirmBtnTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('cartItems');
          FoodFunction.updateCartItemCount(0);

          // Clear the cart first
          cartItems.clear();

          // Now add the new item to the cart
          Map<String, dynamic> item = {
            'name': name,
            'price': price,
            'quantity': quantity,
            'imageUrl': imageUrl,
            'restaurantName': restaurantName,
            'location': location,

            'category': category, // Add category to the item
            'rid': rid,
            'menuType': menuType,
            'distance': distance,
          };

          cartItems.add(jsonEncode(item)); // Add JSON encoded string
          await prefs.setStringList('cartItems', cartItems);
          int newCount = cartItems.length;
          await FoodFunction.updateCartItemCount(newCount);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $quantity $name to cart'),
              backgroundColor: Colors.orange.shade700,
              closeIconColor: Colors.white,
              duration: const Duration(seconds: 2),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context)
              .pop(); // Navigate back after adding the new items
        },
      );
      return;
    }

    // Add new item to cart
    Map<String, dynamic> item = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'restaurantName': restaurantName,
      'location': location,
      'category': category, // Add category to the item
      'rid': rid,
      'distance': distance,
      'menuType': menuType,
    };

    cartItems.add(jsonEncode(item)); // Add JSON encoded string
    await prefs.setStringList('cartItems', cartItems);
    int newCount = cartItems.length;
    await FoodFunction.updateCartItemCount(newCount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $quantity $name to cart'),
        backgroundColor: Colors.orange.shade700,
        closeIconColor: Colors.white,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int itemCount = prefs.getInt('cartItemCount') ?? 0;
    cartItemCountNotifier.value = itemCount;
  }

  static Future<void> updateCartItemCount(int newCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cartItemCount', newCount);
    cartItemCountNotifier.value = newCount;
  }
}

Widget caro2(List<String> bannerImages) {
  return Center(
    child: Builder(
      builder: (context) {
        return FlutterCarousel(
          options: CarouselOptions(
            height: 140,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            enableInfiniteScroll: true,
            showIndicator: false,
            autoPlayInterval: const Duration(seconds: 2),
          ),
          items: bannerImages.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 6.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://admin.maximus.works/admin/menu/${i}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )));
              },
            );
          }).toList(),
        );
      },
    ),
  );
}

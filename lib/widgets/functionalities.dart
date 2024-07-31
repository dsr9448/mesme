import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodFunction {
  static ValueNotifier<int> cartItemCountNotifier = ValueNotifier<int>(0);
   static void addToCart(String name , double price , int quantity, String imageUrl, String restaurantName, String location,BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    int cartItemCount = cartItems.length;
    Map<String, dynamic> item = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'restaurantName': restaurantName,
      'location': location,
    };

    cartItems.add(jsonEncode(item)); // Add JSON encoded string
    await prefs.setStringList('cartItems', cartItems);
    int newCount = cartItems.length;
    await FoodFunction.updateCartItemCount(newCount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $quantity $name to cart'),backgroundColor: Colors.black,closeIconColor: Colors.white,showCloseIcon: true,duration: const Duration(seconds: 3),),
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
            height: 200,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            enableInfiniteScroll: true,
            autoPlayInterval: const Duration(seconds: 2),
            slideIndicator: CircularWaveSlideIndicator(),
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
                          i,
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
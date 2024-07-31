import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodCart extends StatefulWidget {
  const FoodCart({super.key});

  @override
  _FoodCartState createState() => _FoodCartState();
}

class _FoodCartState extends State<FoodCart> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsString = prefs.getStringList('cartItems') ?? [];
    setState(() {
      cartItems = cartItemsString.map((item) {
        Map<String, dynamic> decodedItem =
            jsonDecode(item) as Map<String, dynamic>;
        decodedItem['price'] = double.parse(
            decodedItem['price'].toString()); // Ensure price is a double
        return decodedItem;
      }).toList();
    });
  }

  Future<void> _clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    FoodFunction.updateCartItemCount(0);
    setState(() {
      cartItems.clear();
    });
  }

  Future<void> _updateCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsString =
        cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('cartItems', cartItemsString);
    FoodFunction.updateCartItemCount(-1);
  }

  void _increaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        cartItems[index]['quantity']++;
      });
      _updateCartItems();
    }
  }

  void _decreaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        if (cartItems[index]['quantity'] > 1) {
          cartItems[index]['quantity']--;
        }
      });
      _updateCartItems();
    }
  }

  void _removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        cartItems.removeAt(index);
      });
      _updateCartItems();
    }
  }

  double _calculateTotalAmount() {
    return cartItems.fold(
        0, (total, item) => total + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    // Group items by restaurant name
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in cartItems) {
      if (groupedItems.containsKey(item['restaurantName'])) {
        groupedItems[item['restaurantName']]!.add(item);
      } else {
        groupedItems[item['restaurantName']] = [item];
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cart', style: GoogleFonts.poppins()),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: groupedItems.keys.length,
              itemBuilder: (context, groupIndex) {
                String restaurantName = groupedItems.keys.elementAt(groupIndex);
                List<Map<String, dynamic>> items =
                    groupedItems[restaurantName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.grey[200],
                      child: Text(
                        restaurantName,
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...items.map((item) {
                      int itemIndex = cartItems.indexOf(item);
                      return Dismissible(
                        key: Key(item['name']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeItem(itemIndex);
                        },
                        background: Container(
                          color: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: AlignmentDirectional.centerEnd,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                item['imageUrl'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Location: ${item['location']}',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      '₹${item['price'].toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _decreaseQuantity(itemIndex),
                                        icon: Icon(Icons.remove,
                                            color: Colors.red),
                                      ),
                                      Text('${item['quantity']}',
                                          style: GoogleFonts.poppins()),
                                      IconButton(
                                        onPressed: () =>
                                            _increaseQuantity(itemIndex),
                                        icon: Icon(Icons.add,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () => _removeItem(itemIndex),
                                    icon:
                                        Icon(Icons.delete, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}', // Display total amount as a double
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearCart,
        backgroundColor: Colors.black,
        child: const Icon(Icons.clear, color: Colors.white),
      ),
    );
  }
}

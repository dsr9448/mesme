import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'dart:convert';

import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _searchResults = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        _search(_controller.text);
      } else {
        setState(() {
          _searchResults = {};
        });
      }
    });
  }

  Future<void> _search(String query) async {
    final response = await http.get(
        Uri.parse('https://mesme.in/admin/api/Food/search.php?search=$query'));

    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(50)),
              child: GestureDetector(
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MeLocation(
                            uid: userData?.id ?? '-',
                          )),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Location',
                      style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              color: Colors.black, fontSize: 12))),
                  Text(
                      userData?.address != null
                          ? userData!.address.split(' ').take(3).join(' ') +
                              (userData!.address.split(' ').length > 2
                                  ? '.'
                                  : 'Enter location')
                          : 'Enter location',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.black,
            ),
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.black12)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                hintText: 'Search for Food or Grocery',
                fillColor: Colors.white,
              ),
            ),
            Expanded(
              child: ListView(
                children: _buildResults(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: FoodFunction.cartItemCountNotifier,
        builder: (context, itemCount, child) {
          return FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              Navigator.pushNamed(context, '/FoodCart');
            },
            child: Stack(
              fit: StackFit.expand, // Make the stack fill the button area
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding:
                          const EdgeInsets.all(6), // Adjust padding as needed
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 24, // Adjust size as needed
                        maxHeight: 24, // Adjust size as needed
                      ),
                      child: Center(
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildResults() {
    List<Widget> widgets = [];

    if (_searchResults.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('No results found'),
        )
      ];
    }

    if (_searchResults['foodItems'] != null &&
        _searchResults['foodItems'].isNotEmpty) {
      widgets.add(const Text('Food Items',
          style: TextStyle(fontWeight: FontWeight.bold)));
      var restaurant = _searchResults['restaurants'][0];

      for (var foodItem in _searchResults['foodItems']) {
        widgets.add(ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewItem(
                  imageUrl: foodItem['foodPhoto'],
                  name: foodItem['foodName'],
                  price: double.parse(foodItem['price']),
                  restaurantName: restaurant['name'],
                  location: restaurant['location'],
                  description: foodItem['foodDescription'],
                  rating: foodItem['rating'],
                  isVeg: foodItem['vegOrNonVeg'],
                  food: true,
                ),
              ),
            );
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              foodItem['foodPhoto'],
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(foodItem['foodName']),
          subtitle: Text(
            'Description: ${foodItem['foodDescription']} - Price: ${foodItem['price']}',
          ),
        ));
      }
    }

    if (_searchResults['groceryItems'] != null &&
        _searchResults['groceryItems'].isNotEmpty) {
      widgets.add(const Text('Grocery Items Or Fruits & Vegetables',
          style: TextStyle(fontWeight: FontWeight.bold)));
      for (var item in _searchResults['groceryItems']) {
        widgets.add(ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewItem(
                        imageUrl: item['ImageUrl'],
                        name: item['ItemName'],
                        price: double.parse(item['Price']),
                        restaurantName: 'restaurantName',
                        location: 'location',
                        description: item['Description'],
                        quantity: item['Quantity'],
                        unit: item['Unit'],
                        food: false,
                        isVeg: '',
                        rating: '')));
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['ImageUrl'],
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(item['ItemName']),
          subtitle: Text('Description: ${item['Description']}'),
          // 'Price: ${item['Price']} - Quantity: ${item['Quantity']} ${item['Unit']}'),
        ));
      }
    }

    return widgets;
  }
}

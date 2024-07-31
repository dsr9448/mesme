import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
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
    );
  }

  List<Widget> _buildResults() {
    List<Widget> widgets = [];

    if (_searchResults.isEmpty) {
      return [const Text('No results found')];
    }

    // if (_searchResults['restaurants'] != null) {
    //   widgets.add(const Text('Restaurants',
    //       style: TextStyle(fontWeight: FontWeight.bold)));
    //   for (var restaurant in _searchResults['restaurants']) {
    //     widgets.add(ListTile(
    //       title: Text(restaurant['name']),
    //       subtitle: Text(
    //           'Location: ${restaurant['location']} - Phone: ${restaurant['phoneNumber']}'),
    //     ));
    //   }
    // }

    if (_searchResults['foodItems'] != null &&
        _searchResults['foodItems'].isNotEmpty) {
      widgets.add(const Text('Food Items',
          style: TextStyle(fontWeight: FontWeight.bold)));
      for (var foodItem in _searchResults['foodItems']) {
        widgets.add(ListTile(
          title: Text(foodItem['foodName']),
          subtitle: Text(
              'Description: ${foodItem['foodDescription']} - Price: ${foodItem['price']}'),
        ));
      }
    }

    // if (_searchResults['groceryCategories'] != null) {
    //   widgets.add(const Text('Grocery Categories',
    //       style: TextStyle(fontWeight: FontWeight.bold)));
    //   for (var category in _searchResults['groceryCategories']) {
    //     widgets.add(ListTile(
    //       title: Text(category['CategoryName']),
    //     ));
    //   }
    // }

    if (_searchResults['groceryItems'] != null &&
        _searchResults['groceryItems'].isNotEmpty) {
      widgets.add(const Text('Grocery Items',
          style: TextStyle(fontWeight: FontWeight.bold)));
      for (var item in _searchResults['groceryItems']) {
        widgets.add(ListTile(
          title: Text(item['ItemName']),
          subtitle: Text(
              'Price: ${item['Price']} - Quantity: ${item['Quantity']} ${item['Unit']}'),
        ));
      }
    }

    return widgets;
  }
}

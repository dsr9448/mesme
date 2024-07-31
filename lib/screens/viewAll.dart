import 'package:flutter/material.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/widgets/functionalities.dart';

class FoodItemsApp extends StatefulWidget {
  final List<Map<String, String>> allFoodItems;
  final rname;
  final rlocation;
  final bool food;

  FoodItemsApp(
      {required this.allFoodItems,
      this.rname,
      this.rlocation,
      required this.food});

  @override
  _FoodItemsAppState createState() => _FoodItemsAppState();
}

class _FoodItemsAppState extends State<FoodItemsApp> {
  TextEditingController search = TextEditingController();
  String searchQuery = '';
  String selectedFilter = 'All'; // New variable to track the filter

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredFoodItems = widget.allFoodItems
        .where((item) =>
            item['name']!.toLowerCase().contains(searchQuery.toLowerCase()) &&
            (selectedFilter == 'All' || item['vegOrNonVeg'] == selectedFilter))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        leadingWidth: 24,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                controller: search,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  filled: true,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Search in ${widget.rname}',
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  searchQuery = search.text;
                });
              },
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black)),
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          widget.food
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'All';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedFilter == 'All'
                              ? Colors.white
                              : Colors.black,
                          backgroundColor: selectedFilter == 'All'
                              ? Colors.black
                              : Colors.grey[300],
                        ),
                        child: const Text('All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Veg';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedFilter == 'Veg'
                              ? Colors.white
                              : Colors.black,
                          backgroundColor: selectedFilter == 'Veg'
                              ? Colors.green
                              : Colors.grey[300],
                        ),
                        child: const Text('Veg'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Non-Veg';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedFilter == 'Non-Veg'
                              ? Colors.white
                              : Colors.black,
                          backgroundColor: selectedFilter == 'Non-Veg'
                              ? Colors.red
                              : Colors.grey[300],
                        ),
                        child: const Text('Non-Veg'),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFoodItems.length,
              itemBuilder: (context, index) {
                final item = filteredFoodItems[index];
                return Container(
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.black45))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.food
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        color: item['vegOrNonVeg'] == 'Veg'
                                            ? Colors.green.shade900
                                            : Colors.red.shade900,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                    ),
                                  )
                                : const SizedBox(),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              item['name']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              "₹ ${item['price']!}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border:
                                            Border.all(color: Colors.black45)),
                                    child: const Text('View More'),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ViewItem(
                                                  imageUrl: item['image']!,
                                                  name: item['name']!,
                                                  price: double.parse(
                                                      item['price']!),
                                                  location: widget.rlocation,
                                                  restaurantName: widget.rname,
                                                  description:
                                                      item['description']!,
                                                  isVeg: item['vegOrNonVeg'],
                                                  rating: item['rating'],
                                                  food: widget.food,
                                                  quantity: item['quantity'],
                                                  unit: item['unit'],
                                                )));
                                  },
                                ),
                                const SizedBox(
                                  width: 28,
                                ),
                                IconButton(
                                    style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.black)),
                                    onPressed: () {
                                      FoodFunction.addToCart(
                                          item['name']!,
                                          double.parse(item['price']!),
                                          1,
                                          item['image']!,
                                          widget.rname,
                                          widget.rlocation,
                                          context);
                                    },
                                    color: Colors.white,
                                    icon: const Icon(
                                        Icons.local_grocery_store_rounded))
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['image']!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

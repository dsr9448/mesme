import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FoodItemsApp extends StatefulWidget {
  final List<Map<String, String>> allFoodItems;
  final rname;
  final rlocation;
  final isOnline;
  final userCoordinate;
  final restrauntCoordinate;
  final quantity;
  final unit;
  final bool food;

  FoodItemsApp(
      {required this.allFoodItems,
      this.rname,
      this.rlocation,
      this.isOnline,
      this.userCoordinate,
      this.restrauntCoordinate,
      this.quantity,
      this.unit,
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
    Map<String, dynamic> result =
        isWithin6Km(widget.userCoordinate, widget.restrauntCoordinate);

    bool canAdd = result['distance'] <= 6 ? true : false;

    double distance = result['distance'] ?? 0.0;
    List<Map<String, String>> filteredFoodItems = widget.allFoodItems
        .where((item) =>
            item['name']!.toLowerCase().contains(searchQuery.toLowerCase()) &&
            (selectedFilter == 'All' || item['vegOrNonVeg'] == selectedFilter))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
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
                cursorColor: Colors.orange.shade700,
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
                  backgroundColor: WidgetStatePropertyAll(Colors.orange)),
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                                ? Colors.orange.shade700
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
                                ? Colors.red[800]
                                : Colors.grey[300],
                          ),
                          child: const Text('Non-Veg'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            // Removing Expanded here
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFoodItems.length,
              itemBuilder: (context, index) {
                final item = filteredFoodItems[index];
                return GestureDetector(
                  onTap: () {
                    widget.isOnline == 1
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewItem(
                                  imageUrl: item['image']!,
                                  name: item['name']!,
                                  price: double.parse(item['price']!),
                                  location: widget.rlocation,
                                  restaurantName: widget.rname,
                                  description: item['description']!,
                                  isVeg: item['vegOrNonVeg'],
                                  rating: item['rating'],
                                  food: widget.food,
                                  quantity: item['quantity'],
                                  unit: item['unit'],
                                  canAdd: canAdd,
                                  distance: distance,
                                )))
                        : widget.food
                            ? QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                title: 'Restaurant Offline',
                                text: 'Restaurant is offline at the moment.',
                                confirmBtnText: 'Ok',
                                confirmBtnColor: Colors.orange.shade700,
                              )
                            : QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                title: 'Store Offline',
                                text: 'Store is offline at the moment.',
                                confirmBtnText: 'Ok',
                                confirmBtnColor: Colors.orange.shade700,
                              );
                  },
                  child: Container(
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
                                          borderRadius:
                                              BorderRadius.circular(4)),
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
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                "₹ ${item['price']!.toString().replaceAll('.00', '')}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900),
                              ),
                              widget.isOnline == 1
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                    color: Colors.black45)),
                                            child: const Text('View More'),
                                          ),
                                          onTap: () {
                                            widget.isOnline == 1
                                                ? Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewItem(
                                                              imageUrl: item[
                                                                  'image']!,
                                                              name:
                                                                  item['name']!,
                                                              price: double
                                                                  .parse(item[
                                                                      'price']!),
                                                              location: widget
                                                                  .rlocation,
                                                              restaurantName:
                                                                  widget.rname,
                                                              description: item[
                                                                  'description']!,
                                                              isVeg: item[
                                                                  'vegOrNonVeg'],
                                                              rating: item[
                                                                  'rating'],
                                                              food: widget.food,
                                                              quantity: item[
                                                                  'quantity'],
                                                              unit:
                                                                  item['unit'],
                                                              canAdd: canAdd,
                                                              distance:
                                                                  distance,
                                                            )))
                                                : widget.food
                                                    ? QuickAlert.show(
                                                        context: context,
                                                        type:
                                                            QuickAlertType.info,
                                                        title:
                                                            'Restaurant Offline',
                                                        text:
                                                            'Restaurant is offline at the moment.',
                                                        confirmBtnText: 'Ok',
                                                        confirmBtnColor: Colors
                                                            .orange.shade700,
                                                      )
                                                    : QuickAlert.show(
                                                        context: context,
                                                        type:
                                                            QuickAlertType.info,
                                                        title: 'Store Offline',
                                                        text:
                                                            'Store is offline at the moment.',
                                                        confirmBtnText: 'Ok',
                                                        confirmBtnColor: Colors
                                                            .orange.shade700,
                                                      );
                                          },
                                        ),
                                        const SizedBox(
                                          width: 28,
                                        ),
                                        IconButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      canAdd == true
                                                          ? Colors.orange
                                                          : canAdd == false
                                                              ? Colors.red
                                                              : Colors.orange)),
                                          onPressed: () {
                                            canAdd == true
                                                ? FoodFunction.addToCart(
                                                    item['name']!,
                                                    double.parse(
                                                        item['price']!),
                                                    1,
                                                    item['image']!,
                                                    widget.rname,
                                                    widget.rlocation,
                                                    widget.food
                                                        ? 'Food'
                                                        : 'Grocery',
                                                    context)
                                                : canAdd == false
                                                    ? QuickAlert.show(
                                                        context: context,
                                                        type:
                                                            QuickAlertType.info,
                                                        title:
                                                            'Service not Available',
                                                        text:
                                                            'Service is not available in this location.',
                                                        confirmBtnText: 'Ok',
                                                        confirmBtnColor: Colors
                                                            .orange.shade700,
                                                      )
                                                    : FoodFunction.addToCart(
                                                        item['name']!,
                                                        double.parse(
                                                            item['price']!),
                                                        1,
                                                        item['image']!,
                                                        widget.rname,
                                                        widget.rlocation,
                                                        widget.food
                                                            ? 'Food'
                                                            : 'Grocery',
                                                        context);
                                          },
                                          color: Colors.white,
                                          icon: const Icon(Icons
                                              .local_grocery_store_rounded),
                                        ),
                                      ],
                                    )
                                  : widget.food
                                      ? Text(
                                          'Restaurant Offline ',
                                          style: TextStyle(
                                              color: Colors.red.shade700),
                                        )
                                      : Text(
                                          'Store Offline ',
                                          style: TextStyle(
                                              color: Colors.red.shade700),
                                        ),
                            ],
                          ),
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Stack(
                                  children: [
                                    ColorFiltered(
                                      colorFilter: widget.isOnline == 1
                                          ? const ColorFilter.mode(
                                              Colors.transparent,
                                              BlendMode.multiply,
                                            )
                                          : const ColorFilter.mode(
                                              Colors.black54,
                                              BlendMode.darken,
                                            ),
                                      child: Image.network(
                                        "https://mesme.in/ControlHub/includes/uploads/${item['image']!}",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (widget.isOnline != 1)
                                      Positioned(
                                        top: 8,
                                        left: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade700,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Offline',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: FoodFunction.cartItemCountNotifier,
        builder: (context, itemCount, child) {
          return FloatingActionButton(
            backgroundColor: Colors.orange.shade700,
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
}

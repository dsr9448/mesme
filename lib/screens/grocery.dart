import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/screens/search.dart';
import 'package:mesme/screens/searchGrocery.dart';
import 'package:mesme/screens/viewAll.dart';
import 'package:mesme/widgets/HorizontalScrollGrocery.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:provider/provider.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MeLocation(
                        uid: userData?.id ?? '-',
                      )),
            );
          },
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(50)),
                child: GestureDetector(
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Location',
                      style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              color: Colors.black, fontSize: 12))),
                  Text(
                      userData?.address != null
                          ? userData!.address.split(' ').take(2).join(' ') +
                              (userData.address.split(' ').length > 2 ? '' : '')
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
            ],
          ),
        ),
        actions: [
          IconButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.orange),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Search()),
                );
              },
              icon: const Icon(Icons.search_rounded, color: Colors.white)),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/FoodProfile');
            },
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            for (var grocery in foodProvider.groceries)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            grocery.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodItemsApp(
                                    allFoodItems: grocery.groceryItem
                                        .map((foodItem) => {
                                              'name': foodItem.name,
                                              'price': foodItem.price,
                                              'image': foodItem.imageUrl,
                                              'description':
                                                  foodItem.description,
                                              'vegOrNonVeg': '',
                                              'quantity': foodItem.quantity,
                                              'unit': foodItem.unit,
                                              'rating': ''
                                            })
                                        .toList(),
                                    rname: grocery.ShopName,
                                    rlocation: grocery.location,
                                    food: false,
                                    isOnline: grocery.isOnline ? 1 : 0,
                                    userCoordinate: userData!.location ,
                                    restrauntCoordinate: grocery.coordinates,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text('View all',
                                    style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.w500))),
                                const Icon(Icons.east)
                              ],
                            ),
                          ),
                        ]),
                    HorizontalScrollGrocery(
                      items: grocery.groceryItem,
                      rname: grocery.ShopName,
                      rlocation: grocery.location,
                      isOnline: grocery.isOnline,
                      userCoordinate: userData!.location ,
                      groceryCoordinate: grocery.coordinates,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              )
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

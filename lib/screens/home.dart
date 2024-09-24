import 'package:flutter/material.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/screens/search.dart';
import 'package:mesme/screens/viewAll.dart';
import 'package:mesme/widgets/HorizontalScrollWidget.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    _fetchData(foodProvider);
  }

  Future<void> _fetchData(FoodProvider foodProvider) async {
    await foodProvider.fetchSavedCoordinates();
    await foodProvider.fetchUserData();
    await foodProvider.fetchSavedAddress();
    await foodProvider.fetchOrders();
  }

  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;
    foodProvider.fetchSavedCoordinates();
    foodProvider.fetchRestaurants();

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
                  MaterialPageRoute(builder: (context) => SearchPage()),
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
            caro2(foodProvider.bannerImages),
            const SizedBox(height: 16),
            for (var restaurant in foodProvider.restaurants)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        restaurant.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900),
                      )),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodItemsApp(
                                allFoodItems: restaurant.foodItems
                                    .map((foodItem) => {
                                          'name': foodItem.foodName,
                                          'price': foodItem.price,
                                          'image': foodItem.foodPhoto,
                                          'vegOrNonVeg': foodItem.vegOrNonVeg,
                                          'rating': foodItem.rating,
                                          'quantity': foodItem.Quantity,
                                          'unit': foodItem.Unit,
                                          'description':
                                              foodItem.foodDescription,
                                        })
                                    .toList(),
                                rname: restaurant.name,
                                rlocation: restaurant.location,
                                food: true,
                                isOnline: restaurant.isOnline ? 1 : 0,
                                userCoordinate: userData!.location,
                                restrauntCoordinate: restaurant.coordinates,
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
                    ],
                  ),
                  // const SizedBox(height: 12),
                  HorizontalScrollWidget(
                    items: restaurant.foodItems,
                    rname: restaurant.name,
                    rlocation: restaurant.location,
                    isOnline: restaurant.isOnline,
                    userCoordinate: userData!.location,
                    restrauntCoordinate: restaurant.coordinates,
                  ),
                  const SizedBox(height: 24),
                ],
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

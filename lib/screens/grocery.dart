import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/screens/searchGrocery.dart';
import 'package:mesme/screens/viewAllGrocery.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:mesme/widgets/customSwitch.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:provider/provider.dart';
import 'package:mesme/widgets/preloder.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;

    return foodProvider.groceries.isEmpty
        ? buildShimmerLoader(false)
        : Scaffold(
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
                                ? userData!.address
                                        .split(' ')
                                        .take(2)
                                        .join(' ') +
                                    (userData.address.split(' ').length > 2
                                        ? ''
                                        : '')
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
                    icon:
                        const Icon(Icons.search_rounded, color: Colors.white)),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: customHeading(
                        'Top (${foodProvider.groceries.length}) Sweets to explore'),
                  ),
                  const SizedBox(height: 12),
                  for (var grocery in foodProvider.groceries)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroceryItemsApp(
                              allFoodItems: grocery.groceryItem
                                  .map((foodItem) => {
                                        'name': foodItem.name,
                                        'price': foodItem.price,
                                        'image': foodItem.imageUrl,
                                        'description': foodItem.description,
                                        'vegOrNonVeg': 'veg',
                                        'quantity': foodItem.quantity,
                                        'unit': foodItem.unit,
                                        'rating': '',
                                        'category': foodItem.category,
                                        'totalCount': '',
                                      })
                                  .toList(),
                              rname: grocery.ShopName,
                              rlocation: grocery.location,
                              food: false,
                              isOnline: grocery.isOnline ? 1 : 0,
                              userCoordinate: userData.location,
                              restrauntCoordinate: grocery.coordinates,
                              description: grocery.description,
                              restraurantImage:
                                  'https://mesme.inkaradigital.com/mainBanner.jpg',
                              area: grocery.area,
                              time: grocery.time,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Restaurant Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                "https://mesme.inkaradigital.com/admin/foodPhoto.jpg",
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Restaurant Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Restaurant Name
                                  Text(
                                    grocery.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 2),

                                  // Rating and Time
                                  Row(children: [
                                    Icon(Icons.access_time,
                                        size: 16, color: Colors.grey),
                                    Text(
                                      " ${grocery.time}",
                                      // " ${'restaurant.rating'} • ${'restaurant.time'}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ]),

                                  const SizedBox(height: 2),

                                  // Description
                                  Text(
                                    grocery.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 2),

                                  // Location
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 16, color: Colors.grey),
                                      SizedBox(width: 2),
                                      Text(
                                        grocery.area,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(" • "),
                                      Expanded(
                                        child: Text(
                                          '${(isWithin6Km(userData!.location, grocery.coordinates)['distance']).toStringAsFixed(2)} Km ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            padding: const EdgeInsets.all(
                                6), // Adjust padding as needed
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/grocery_model.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/viewAll.dart';
import 'package:mesme/widgets/HorizontalScrollGrocery.dart';
import 'package:mesme/widgets/HorizontalScrollWidget.dart';
import 'package:provider/provider.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              color: Colors.black, fontSize: 12),
                        ),
                      ),
                      Text(
                        'Enter location',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 36),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/FoodProfile');
              },
              icon: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            for (var grocery in foodProvider.groceries)
              Column(
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
                                            'description': foodItem.description,
                                            'vegOrNonVeg': '',
                                            'quantity': foodItem.quantity,
                                            'unit': foodItem.unit,
                                            'rating': ''
                                          })
                                      .toList(),
                                  rname: grocery.name,
                                  rlocation: '',
                                  food: false,
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
                      items: grocery.groceryItem, rname: '', rlocation: ''),
                  // HorizontalScrollWidget(items: grocery.groceryItem, rname: '',rlocation: '',)
                ],
              )
          ],
        ),
      ),
      // body: foodProvider.isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : Container(
      //         color: Colors.white,
      //         padding: const EdgeInsets.all(8),
      //         child: ListView(
      //           children: foodProvider.groceries.map((category) {
      //             List<GroceryItem>? items =
      //                 foodProvider.groceryCategoriesMap[category.id];

      //             return Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Row(
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     Text(
      //                       category.name,
      //                       style: TextStyle(
      //                           fontWeight: FontWeight.bold, fontSize: 20),
      //                     ),
      //                     GestureDetector(
      //                       onTap: (){
      //                     //     Navigator.push(
      //                     //   context,
      //                     //   MaterialPageRoute(
      //                     //     builder: (context) => FoodItemsApp(
      //                     //       allFoodItems: items.Grcer
      //                     //           .map((foodItem) => {
      //                     //                 'name': foodItem.foodName,
      //                     //                 'price': foodItem.price,
      //                     //                 'image': foodItem.foodPhoto,
      //                     //                 'vegOrNonVeg': foodItem.vegOrNonVeg,
      //                     //                 'rating': foodItem.rating
      //                     //               })
      //                     //           .toList(),
      //                     //       rname: 'restaurant.name',
      //                     //       rlocation: 'restaurant.location',
      //                     //     ),
      //                     //   ),
      //                     // );
      //                       },
      //                       child: Row(
      //                         children: [
      //                           Text('View all',
      //                               style: GoogleFonts.poppins(
      //                                   textStyle: const TextStyle(
      //                                       fontWeight: FontWeight.w500))),
      //                           const Icon(Icons.east)
      //                         ],
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(height: 16),
      //                 SizedBox(
      //                   height: 120,
      //                   child: ListView.builder(
      //                     scrollDirection: Axis.horizontal,
      //                     itemCount: items?.length ?? 0,
      //                     itemBuilder: (context, index) {
      //                       final item = items![index];
      //                       return Container(
      //                         margin: const EdgeInsets.only(right: 8),
      //                         child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           children: [
      //                             ClipRRect(
      //                               borderRadius: BorderRadius.circular(50),
      //                               child: Image.network(
      //                                 item.imageUrl,
      //                                 fit: BoxFit.cover,
      //                                 height:
      //                                     100, // Set the height of the image
      //                                 width: 100, // Set the width of the image
      //                               ),
      //                             ),
      //                             Text(
      //                               item.name,
      //                             ),
      //                           ],
      //                         ),
      //                       );
      //                     },
      //                   ),
      //                 ),
      //                 const SizedBox(height: 16),
      //               ],
      //             );
      //           }).toList(),
      //         ),
      //       ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.black,
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/FoodCart');
      //   },
      //   child: const Icon(Icons.shopping_cart, color: Colors.white),
      // ),
    );
  }
}

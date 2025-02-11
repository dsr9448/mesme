// import 'package:flutter/material.dart';
// import 'package:mesme/models/usermodel.dart';
// import 'package:mesme/provider/provider.dart';
// import 'package:mesme/screens/location.dart';
// import 'package:mesme/screens/viewAll.dart';
// import 'package:mesme/screens/ViewItem.dart';
// import 'package:mesme/widgets/HorizontalScrollWidget.dart';
// import 'package:mesme/widgets/functionalities.dart';
// import 'package:mesme/widgets/wishlist.dart';
// import 'package:mesme/widgets/calculateLocation.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Map<String, dynamic> _searchResults = {};
//   OverlayEntry? _overlayEntry;

//   final GlobalKey _searchKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     final foodProvider = Provider.of<FoodProvider>(context, listen: false);
//     _fetchData(foodProvider);
//   }

//   @override
//   void dispose() {
//     _hideOverlay();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _hideOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   Future<void> _search(String query) async {
//     if (query.isEmpty) {
//       _hideOverlay();
//       setState(() {
//         _searchResults = {};
//       });
//       return;
//     }

//     try {
//       final response = await http.get(Uri.parse(
//           'https://mesme.in/admin/api/Food/search.php?search=$query'));

//       if (response.statusCode == 200) {
//         setState(() {
//           _searchResults = json.decode(response.body);
//         });
//         _showOverlay();
//       }
//     } catch (e) {
//       print('Search error: $e');
//     }
//   }

//   void _showOverlay() {
//     _hideOverlay();

//     if (_searchResults.isEmpty ||
//         !(_searchResults['restaurants'] is Map) ||
//         (_searchResults['restaurants'] as Map).isEmpty) {
//       return;
//     }

//     final RenderBox searchBox =
//         _searchKey.currentContext!.findRenderObject() as RenderBox;
//     final searchPosition = searchBox.localToGlobal(Offset.zero);

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: searchPosition.dy + searchBox.size.height + 5,
//         left: 16,
//         right: 16,
//         child: Material(
//           elevation: 8,
//           borderRadius: BorderRadius.circular(15),
//           child: Container(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.4,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: ListView.builder(
//               shrinkWrap: true,
//               padding: EdgeInsets.zero,
//               itemCount: (_searchResults['restaurants'] as Map)
//                   .values
//                   .expand(
//                       (restaurant) => (restaurant['foodItems'] as List? ?? []))
//                   .length,
//               itemBuilder: (context, index) {
//                 var allFoodItems = (_searchResults['restaurants'] as Map)
//                     .values
//                     .expand((restaurant) =>
//                         (restaurant['foodItems'] as List? ?? []))
//                     .toList();
//                 var foodItem = allFoodItems[index];
//                 var restaurant = (_searchResults['restaurants'] as Map)
//                     .values
//                     .firstWhere((r) =>
//                         (r['foodItems'] as List? ?? []).contains(foodItem));
//                 var restaurantDetails = restaurant['restaurantDetails'];

//                 return ListTile(
//                   onTap: () {
//                     _hideOverlay();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ViewItem(
//                           imageUrl: foodItem['foodPhoto'],
//                           name: foodItem['foodName'],
//                           price: double.parse(foodItem['price'].toString()),
//                           restaurantName: restaurantDetails['name'],
//                           location: restaurantDetails['location'],
//                           description: foodItem['foodDescription'],
//                           quantity: foodItem['Quantity'],
//                           unit: foodItem['Unit'],
//                           rating: foodItem['rating'],
//                           isVeg: foodItem['vegOrNonVeg'],
//                           food: true,
//                           canAdd: isWithin6Km(
//                                       Provider.of<FoodProvider>(context,
//                                                   listen: false)
//                                               .userData
//                                               ?.location ??
//                                           '0,0',
//                                       restaurantDetails['coordinates'])[
//                                   'distance'] <=
//                               6,
//                           distance: isWithin6Km(
//                                       Provider.of<FoodProvider>(context,
//                                                   listen: false)
//                                               .userData
//                                               ?.location ??
//                                           '0,0',
//                                       restaurantDetails['coordinates'])[
//                                   'distance'] ??
//                               0.0,
//                         ),
//                       ),
//                     );
//                   },
//                   leading: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       "https://mesme.in/ControlHub/includes/uploads/${foodItem['foodPhoto']}",
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         width: 50,
//                         height: 50,
//                         color: Colors.grey[300],
//                         child: Icon(Icons.error),
//                       ),
//                     ),
//                   ),
//                   title: Text(foodItem['foodName']),
//                   subtitle: Text(restaurantDetails['name']),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   Future<void> _fetchData(FoodProvider foodProvider) async {
//     await foodProvider.fetchSavedCoordinates();
//     await foodProvider.fetchUserData();
//     await foodProvider.fetchSavedAddress();
//     await foodProvider.fetchOrders();
//   }

//   Widget build(BuildContext context) {
//     final foodProvider = Provider.of<FoodProvider>(context);
//     UserModel? userData = foodProvider.userData;
//     foodProvider.fetchSavedCoordinates();
//     foodProvider.fetchRestaurants();

//     return GestureDetector(
//       onTap: _hideOverlay,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: ListView(
//             children: [
//               Container(
//                 height: 280,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage(
//                         'https://mesme.in/mainBanner.jpg'),
//                     fit: BoxFit.cover,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black.withOpacity(0.4),
//                       BlendMode.darken,
//                     ),
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => MeLocation(
//                                     uid: userData?.id ?? '-',
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.shade700,
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                   child: const Icon(
//                                     Icons.location_on_outlined,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Your Location',
//                                       style: GoogleFonts.poppins(
//                                         textStyle: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       userData?.address != null
//                                           ? userData!.address
//                                               .split(' ')
//                                               .take(2)
//                                               .join(' ')
//                                           : 'Enter location',
//                                       style: GoogleFonts.poppins(
//                                         textStyle: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             style: ButtonStyle(
//                               backgroundColor: WidgetStatePropertyAll(
//                                   Colors.orange.shade700),
//                               shape: WidgetStatePropertyAll(CircleBorder()),
//                             ),
//                             onPressed: () {
//                               Navigator.pushNamed(context, '/FoodProfile');
//                             },
//                             icon: const Icon(Icons.person, color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: TextField(
//                         key: _searchKey,
//                         controller: _searchController,
//                         style: const TextStyle(color: Colors.black),
//                         cursorColor: Colors.orange.shade700,
//                         onChanged: _search,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           prefixIcon:
//                               const Icon(Icons.search, color: Colors.orange),
//                           hintText: 'Search Restaurant',
//                           hintStyle: const TextStyle(color: Colors.black38),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: caro2(foodProvider.bannerImages),
//               ),
//               const SizedBox(height: 12),
//               RestaurantList(),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: foodProvider.restaurants.length,
//                   itemBuilder: (context, index) {
//                     var restaurant = foodProvider.restaurants[index];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 restaurant.name,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w900,
//                                 ),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => FoodItemsApp(
//                                       allFoodItems: restaurant.foodItems
//                                           .map((foodItem) => {
//                                                 'name': foodItem.foodName,
//                                                 'price': foodItem.price,
//                                                 'image': foodItem.foodPhoto,
//                                                 'vegOrNonVeg':
//                                                     foodItem.vegOrNonVeg,
//                                                 'rating': foodItem.rating,
//                                                 'quantity': foodItem.Quantity,
//                                                 'unit': foodItem.Unit,
//                                                 'description':
//                                                     foodItem.foodDescription,
//                                               })
//                                           .toList(),
//                                       rname: restaurant.name,
//                                       rlocation: restaurant.location,
//                                       food: true,
//                                       isOnline: restaurant.isOnline ? 1 : 0,
//                                       userCoordinate: userData!.location,
//                                       restrauntCoordinate:
//                                           restaurant.coordinates,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     'View all',
//                                     style: GoogleFonts.poppins(
//                                       textStyle: const TextStyle(
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                   const Icon(Icons.east),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         HorizontalScrollWidget(
//                           items: restaurant.foodItems,
//                           rname: restaurant.name,
//                           rlocation: restaurant.location,
//                           isOnline: restaurant.isOnline,
//                           userCoordinate: userData!.location,
//                           restrauntCoordinate: restaurant.coordinates,
//                         ),
//                         const SizedBox(height: 24),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: ValueListenableBuilder<int>(
//           valueListenable: FoodFunction.cartItemCountNotifier,
//           builder: (context, itemCount, child) {
//             return FloatingActionButton(
//               backgroundColor: Colors.orange.shade700,
//               onPressed: () {
//                 Navigator.pushNamed(context, '/FoodCart');
//               },
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   const Icon(Icons.shopping_cart, color: Colors.white),
//                   if (itemCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: const BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         constraints: const BoxConstraints(
//                           maxWidth: 24,
//                           maxHeight: 24,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$itemCount',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


    // HorizontalScrollGrocery(
                    //   items: grocery.groceryItem,
                    //   rname: grocery.ShopName,
                    //   rlocation: grocery.location,
                    //   isOnline: grocery.isOnline,
                    //   userCoordinate: userData!.location ,
                    //   groceryCoordinate: grocery.coordinates,
                    // ),








                    //  GestureDetector(
                    //         onTap: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => GroceryItemsApp(
                    //                 allFoodItems: grocery.groceryItem
                    //                     .map((foodItem) => {
                    //                           'name': foodItem.name,
                    //                           'price': foodItem.price,
                    //                           'image': foodItem.imageUrl,
                    //                           'description':
                    //                               foodItem.description,
                    //                           'vegOrNonVeg': '',
                    //                           'quantity': foodItem.quantity,
                    //                           'unit': foodItem.unit,
                    //                           'rating': ''
                    //                         })
                    //                     .toList(),
                    //                 rname: grocery.ShopName,
                    //                 rlocation: grocery.location,
                    //                 food: false,
                    //                 isOnline: grocery.isOnline ? 1 : 0,
                    //                 userCoordinate: userData!.location ,
                    //                 restrauntCoordinate: grocery.coordinates,
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         child: Row(
                    //           children: [
                    //             Text('View all',
                    //                 style: GoogleFonts.poppins(
                    //                     textStyle: const TextStyle(
                    //                         fontWeight: FontWeight.w500))),
                    //             const Icon(Icons.east)
                    //           ],
                    //         ),
                    //       ),
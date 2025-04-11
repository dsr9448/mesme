import 'package:flutter/material.dart';
import 'package:mesme/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/screens/viewAll.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/widgets/customSwitch.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:mesme/widgets/preloder.dart';
import 'package:mesme/widgets/wishlist.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _restaurantSearchController =
      TextEditingController();
  Map<String, dynamic> _searchResults = {};
  OverlayEntry? _overlayEntry;
  final GlobalKey _searchKey = GlobalKey();
  String selectedFilter = 'All';
  String restaurantSearchQuery = '';
  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    _fetchData(foodProvider);
  }

  @override
  void dispose() {
    _restaurantSearchController.dispose();
    _hideOverlay();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _hideOverlay();
      setState(() {
        _searchResults = {};
      });
      return;
    }

    // Cancel any existing timer
    _searchDebounceTimer?.cancel();

    // Start a new timer
    _searchDebounceTimer = Timer(_searchDebounceDuration, () async {
      try {
        final response = await http.get(Uri.parse(
            'https://admin.maximus.works/admin/api/Food/search.php?search=$query'));

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _searchResults = json.decode(response.body);
            });
            _showOverlay();
          }
        }
      } catch (e) {
        print('Search error: $e');
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();

    if (_searchResults.isEmpty ||
        !(_searchResults['restaurants'] is Map) ||
        (_searchResults['restaurants'] as Map).isEmpty) {
      return;
    }

    final RenderBox searchBox =
        _searchKey.currentContext!.findRenderObject() as RenderBox;
    final searchPosition = searchBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: searchPosition.dy + searchBox.size.height + 5,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: (_searchResults['restaurants'] as Map)
                  .values
                  .expand(
                      (restaurant) => (restaurant['foodItems'] as List? ?? []))
                  .length,
              itemBuilder: (context, index) {
                var allFoodItems = (_searchResults['restaurants'] as Map)
                    .values
                    .expand((restaurant) =>
                        (restaurant['foodItems'] as List? ?? []))
                    .toList();
                var foodItem = allFoodItems[index];
                var restaurant = (_searchResults['restaurants'] as Map)
                    .values
                    .firstWhere((r) =>
                        (r['foodItems'] as List? ?? []).contains(foodItem));
                var restaurantDetails = restaurant['restaurantDetails'];

                return ListTile(
                  onTap: () {
                    _hideOverlay();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewItem(
                          imageUrl: foodItem['foodPhoto'],
                          name: foodItem['foodName'],
                          price: double.parse(foodItem['price'].toString()),
                          location: restaurantDetails['location'],
                          rid: restaurantDetails['rid'],
                          menuType: foodItem['category'],
                          restaurantName: restaurantDetails['name'],
                          description: foodItem['foodDescription'],
                          quantity: foodItem['Quantity'],
                          unit: foodItem['Unit'],
                          stock: foodItem['stock'],
                          rating: foodItem['rating'],
                          isVeg: foodItem['vegOrNonVeg'],
                          restrauntCoordinate: restaurantDetails['coordinates'],
                          food: true,
                          canAdd: isWithin6Km(
                                      Provider.of<FoodProvider>(context,
                                                  listen: false)
                                              .userData
                                              ?.location ??
                                          '0,0',
                                      restaurantDetails['coordinates'])[
                                  'distance'] <=
                              6,
                          distance: isWithin6Km(
                                      Provider.of<FoodProvider>(context,
                                                  listen: false)
                                              .userData
                                              ?.location ??
                                          '0,0',
                                      restaurantDetails['coordinates'])[
                                  'distance'] ??
                              0.0,
                        ),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://admin.maximus.works/admin/menu/${foodItem['foodPhoto']}",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                  title: Text(foodItem['foodName']),
                  subtitle: Text(restaurantDetails['name']),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _fetchData(FoodProvider foodProvider) async {
    try {
      await Future.wait([
        foodProvider.fetchUserData(),
        foodProvider.fetchRestaurants(),
      ]);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;
    foodProvider.fetchSavedCoordinates();
    foodProvider.fetchRestaurants();
    foodProvider.fetchWishlist();
    String searchQuery = '';
    addToWishlist(int restaurantId) async {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      try {
        await foodProvider.addToWishlist(restaurantId);
        await foodProvider.fetchRestaurants();
        await foodProvider.fetchWishlist();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item added to wishlist'),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 2),
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            closeIconColor: Colors.white,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to wishlist'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 2),
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            closeIconColor: Colors.white,
          ),
        );
      }
    }

    return foodProvider.restaurants.isEmpty ||
            foodProvider.bannerImages.isEmpty ||
            foodProvider.restaurantsAbove4.isEmpty
        ? buildShimmerLoader(true)
        : GestureDetector(
            onTap: _hideOverlay,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://admin.maximus.works/mainBanner.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4),
                              BlendMode.darken,
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MeLocation(
                                            uid: userData?.id ?? '-',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade700,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your Location',
                                              style: GoogleFonts.poppins(
                                                textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              userData?.address != null
                                                  ? userData!.address
                                                      .split(' ')
                                                      .take(2)
                                                      .join(' ')
                                                  : 'Enter location',
                                              style: GoogleFonts.poppins(
                                                textStyle: const TextStyle(
                                                  color: Colors.white,
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
                                  IconButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.orange.shade700),
                                      shape: WidgetStatePropertyAll(
                                          CircleBorder()),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/FoodProfile');
                                    },
                                    icon: const Icon(Icons.person,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                key: _searchKey,
                                controller: _searchController,
                                style: const TextStyle(color: Colors.black),
                                cursorColor: Colors.orange.shade700,
                                onChanged: _search,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.search,
                                      color: Colors.orange),
                                  hintText: 'Are you Hungry!!!',
                                  hintStyle:
                                      const TextStyle(color: Colors.black38),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8),
                      //   child: caro2(foodProvider.bannerImages),
                      // ),
                      const SizedBox(height: 12),
                      RestaurantList(
                        title: '${userData!.name}',
                        location: userData.location,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: customHeading(
                      //       'Top (${foodProvider.restaurants.length}) restaurants to explore'),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 8),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: TextField(
                                controller: _restaurantSearchController,
                                decoration: InputDecoration(
                                  hintText: 'Search restaurants...',
                                  prefixIcon: Icon(Icons.search,
                                      color: Colors.orange.shade700),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade700),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade700),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade700,
                                        width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    restaurantSearchQuery = value.toLowerCase();
                                  });
                                },
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  customSwitch(Colors.orange.shade700,
                                      selectedFilter == 'All', (val) {
                                    setState(() => selectedFilter = 'All');
                                  }),
                                  customSwitch(
                                      Colors.green, selectedFilter == 'Veg',
                                      (val) {
                                    setState(() => selectedFilter = 'Veg');
                                  }),
                                  customSwitch(Colors.red[800]!,
                                      selectedFilter == 'Non-Veg', (val) {
                                    setState(() => selectedFilter = 'Non-Veg');
                                  }),
                                  customSwitch(
                                      Colors.orange, selectedFilter == 'rating',
                                      (val) {
                                    setState(() => selectedFilter = 'rating');
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // padding: const EdgeInsets.all(8),
                        child: Consumer<FoodProvider>(
                            builder: (context, provider, child) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                foodProvider.restaurants.where((restaurant) {
                              if (restaurantSearchQuery.isEmpty) return true;
                              return restaurant.name
                                      .toLowerCase()
                                      .contains(restaurantSearchQuery) ||
                                  restaurant.area
                                      .toLowerCase()
                                      .contains(restaurantSearchQuery) ||
                                  restaurant.description
                                      .toLowerCase()
                                      .contains(restaurantSearchQuery);
                            }).length,
                            itemBuilder: (context, index) {
                              var filteredRestaurants =
                                  foodProvider.restaurants.where((restaurant) {
                                if (restaurantSearchQuery.isEmpty) return true;
                                return restaurant.name
                                        .toLowerCase()
                                        .contains(restaurantSearchQuery) ||
                                    restaurant.area
                                        .toLowerCase()
                                        .contains(restaurantSearchQuery) ||
                                    restaurant.description
                                        .toLowerCase()
                                        .contains(restaurantSearchQuery);
                              }).toList();

                              var restaurant = filteredRestaurants[index];
                              List<int> wishlistIds = foodProvider.restaurant
                                  .map((r) => r.id)
                                  .toList();

                              Map<String, dynamic> result = isWithin6Km(
                                  userData.location, restaurant.coordinates);

                              double distance = result['distance'] ?? 0.0;

                              // Skip restaurants beyond 8km
                              if (distance > 8.0) {
                                return SizedBox.shrink();
                              }

                              // Apply filters based on selectedFilter
                              if ((selectedFilter == 'Veg' &&
                                      restaurant.style != 'veg') ||
                                  (selectedFilter == 'Non-Veg' &&
                                      restaurant.style == 'veg') ||
                                  (selectedFilter == 'rating' &&
                                      double.parse(restaurant.rating ?? "0.0") <
                                          4.0)) {
                                return SizedBox.shrink(); // Skip this item
                              }

                              // Determine background color based on distance
                              Color backgroundColor;
                              if (index < foodProvider.restaurants.length - 1) {
                                var nextRestaurant =
                                    foodProvider.restaurants[index + 1];
                                Map<String, dynamic> nextResult = isWithin6Km(
                                    userData.location,
                                    nextRestaurant.coordinates);
                                double nextDistance =
                                    nextResult['distance'] ?? 0.0;

                                backgroundColor = (distance == nextDistance)
                                    ? Colors
                                        .grey.shade200 // Light grey background
                                    : Colors.transparent; // No background
                              } else {
                                backgroundColor = Colors.transparent;
                                // No background for the last item
                              }

                              return Container(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 8, right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FoodItemsApp(
                                                allFoodItems: restaurant
                                                    .foodItems
                                                    .map((foodItem) => {
                                                          'name':
                                                              foodItem.foodName,
                                                          'price':
                                                              foodItem.price,
                                                          'image': foodItem
                                                              .foodPhoto,
                                                          'vegOrNonVeg':
                                                              foodItem
                                                                  .vegOrNonVeg,
                                                          'rating':
                                                              foodItem.rating,
                                                          'quantity':
                                                              foodItem.Quantity,
                                                          'unit': foodItem.Unit,
                                                          'stock': foodItem
                                                              .stock
                                                              .toString(),
                                                          'description': foodItem
                                                              .foodDescription,
                                                          'category':
                                                              foodItem.category,
                                                          'totalCount': foodItem
                                                              .totalCount
                                                              .toString()
                                                        })
                                                    .toList(),
                                                rname: restaurant.name,
                                                rlocation: restaurant.location,
                                                food: true,
                                                rid: restaurant.rid,
                                                isOnline:
                                                    restaurant.isOnline ? 1 : 0,
                                                userCoordinate:
                                                    userData.location,
                                                rating: restaurant.rating,
                                                restrauntCoordinate:
                                                    restaurant.coordinates,
                                                restraurantImage: restaurant
                                                        .rphoto.isNotEmpty
                                                    ? 'https://admin.maximus.works/admin/restrauntimage/${restaurant.rphoto}'
                                                    : 'https://admin.maximus.works/mainBanner.jpg',
                                                time: restaurant.rtime,
                                                description:
                                                    restaurant.description,
                                                area: restaurant.area,
                                                style: restaurant.style,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Restaurant Image
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: ColorFiltered(
                                                      colorFilter: (!restaurant
                                                              .isOnline)
                                                          ? const ColorFilter
                                                              .mode(
                                                              Colors.black54,
                                                              BlendMode.darken)
                                                          : const ColorFilter
                                                              .mode(
                                                              Colors
                                                                  .transparent,
                                                              BlendMode
                                                                  .multiply),
                                                      child: Image.network(
                                                        "https://admin.maximus.works/admin/menu/${restaurant.foodItems[0].foodPhoto}",
                                                        height: 150,
                                                        width: 150,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Image.network(
                                                            "https://admin.maximus.works/admin/foodPhoto.jpg",
                                                            height: 150,
                                                            width: 150,
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  (!restaurant.isOnline)
                                                      ? Positioned(
                                                          top: 8,
                                                          left: 5,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .orange
                                                                  .shade700,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              'Offline',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                  Positioned(
                                                    top: 8,
                                                    right: 4,
                                                    child:
                                                        wishlistIds.contains(
                                                                restaurant.id)
                                                            ? GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  try {
                                                                    await foodProvider
                                                                        .removeFromWishlist(
                                                                            restaurant.id);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            const Text('Item  Removed From  wishlist'),
                                                                        backgroundColor: Colors
                                                                            .green
                                                                            .shade800,
                                                                        duration:
                                                                            const Duration(seconds: 2),
                                                                        showCloseIcon:
                                                                            true,
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        closeIconColor:
                                                                            Colors.white,
                                                                      ),
                                                                    );
                                                                  } catch (e) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text('Failed to remove item to wishlist'),
                                                                        backgroundColor: Colors
                                                                            .red
                                                                            .shade800,
                                                                        duration:
                                                                            const Duration(seconds: 2),
                                                                        showCloseIcon:
                                                                            true,
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        closeIconColor:
                                                                            Colors.white,
                                                                      ),
                                                                    );
                                                                  }
                                                                  setState(
                                                                      () {}); // Force UI update
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .favorite,
                                                                  color: Colors
                                                                      .red
                                                                      .shade800,
                                                                  size: 25,
                                                                ),
                                                              )
                                                            : GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  try {
                                                                    await foodProvider
                                                                        .addToWishlist(
                                                                            restaurant.id);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            const Text('Item added to wishlist'),
                                                                        backgroundColor: Colors
                                                                            .green
                                                                            .shade800,
                                                                        duration:
                                                                            const Duration(seconds: 2),
                                                                        showCloseIcon:
                                                                            true,
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        closeIconColor:
                                                                            Colors.white,
                                                                      ),
                                                                    );
                                                                  } catch (e) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text('Failed to add item to wishlist'),
                                                                        backgroundColor: Colors
                                                                            .red
                                                                            .shade800,
                                                                        duration:
                                                                            const Duration(seconds: 2),
                                                                        showCloseIcon:
                                                                            true,
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        closeIconColor:
                                                                            Colors.white,
                                                                      ),
                                                                    );
                                                                  }
                                                                  setState(
                                                                      () {}); // Force UI update
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .favorite_outline,
                                                                  color: Colors
                                                                      .orange
                                                                      .shade800,
                                                                  size: 25,
                                                                ),
                                                              ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 12),

                                              // Restaurant Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Restaurant Name
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: 20,
                                                              width: 20,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: restaurant.style == 'veg' ||
                                                                              restaurant.style ==
                                                                                  'both'
                                                                          ? Colors
                                                                              .green
                                                                              .shade900
                                                                          : Colors
                                                                              .red
                                                                              .shade900,
                                                                      width: 2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4)),
                                                              child: Icon(
                                                                Icons.circle,
                                                                size: 10,
                                                                color: restaurant.style ==
                                                                            'veg' ||
                                                                        restaurant.style ==
                                                                            'both'
                                                                    ? Colors
                                                                        .green
                                                                        .shade900
                                                                    : Colors.red
                                                                        .shade900,
                                                              ),
                                                            ),
                                                            if (restaurant
                                                                    .style ==
                                                                'both') ...[
                                                              SizedBox(
                                                                  width: 4),
                                                              Container(
                                                                height: 20,
                                                                width: 20,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .red
                                                                            .shade900,
                                                                        width:
                                                                            2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4)),
                                                                child: Icon(
                                                                  Icons.circle,
                                                                  size: 10,
                                                                  color: Colors
                                                                      .red
                                                                      .shade900,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        double.parse(restaurant
                                                                        .rating ??
                                                                    "0.0") >=
                                                                4.0
                                                            ? Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .orange, // Best Seller tag color
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                                child: Text(
                                                                  "Best Seller",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox(),
                                                      ],
                                                    ),

                                                    Text(
                                                      restaurant.name,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),

                                                    const SizedBox(height: 2),

                                                    // Rating and Time
                                                    Row(
                                                      children: [
                                                        Icon(Icons.star,
                                                            color:
                                                                Colors.orange,
                                                            size: 16),
                                                        Text(
                                                          " ${restaurant.rating}(${restaurant.totalOrders}) • ${restaurant.time}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 2),

                                                    // Description
                                                    Text(
                                                      '${restaurant.description}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),

                                                    const SizedBox(height: 2),

                                                    // Location
                                                    Row(
                                                      children: [
                                                        Text(
                                                          restaurant.area,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(" • "),
                                                        Expanded(
                                                          child: Text(
                                                            '${distance.toStringAsFixed(2)} Km ',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
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
                      fit: StackFit.expand,
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        if (itemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 24,
                                maxHeight: 24,
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
            ),
          );
  }
}

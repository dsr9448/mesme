import 'package:flutter/material.dart';
import 'package:mesme/models/RestaurantCardmodel.dart';
import 'package:mesme/screens/viewAll.dart';
import 'package:mesme/widgets/customSwitch.dart';
import 'package:mesme/provider/provider.dart';
import 'package:provider/provider.dart';

class RestaurantList extends StatefulWidget {
  final String title;
  final String location;
  RestaurantList({required this.title, required this.location});

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  final List<Map<String, dynamic>> restaurants = [];

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    foodProvider.fetchWishlist();

    return Column(
      children: [
        (foodProvider.restaurant.length != 0)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customHeading("${widget.title}'s Favorite Restaurants"),
                    SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      height: 245,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: foodProvider.restaurant.length,
                        itemBuilder: (context, index) {
                          var restaurant = foodProvider.restaurant[index];
                          return GestureDetector(
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
                                              'vegOrNonVeg':
                                                  foodItem.vegOrNonVeg,
                                              'rating': foodItem.rating,
                                              'quantity': foodItem.Quantity,
                                              'unit': foodItem.Unit,
                                              'description':
                                                  foodItem.foodDescription,
                                              'stock':
                                                  foodItem.stock.toString(),
                                              'category': foodItem.category,
                                              'totalCount':
                                                  foodItem.totalCount.toString()
                                            })
                                        .toList(),
                                    rname: restaurant.name,
                                    rid: restaurant.id.toString(),
                                    rlocation: restaurant.location,
                                    food: true,
                                    isOnline: restaurant.isOnline ? 1 : 0,
                                    userCoordinate: widget.location,
                                    rating: restaurant.rating,
                                    restrauntCoordinate: restaurant.coordinates,
                                    restraurantImage: restaurant
                                            .rphoto.isNotEmpty
                                        ? 'https://admin.maximus.works/admin/restrauntimage/${restaurant.rphoto}'
                                        : 'https://admin.maximus.works/mainBanner.jpg',
                                    time: restaurant.rtime,
                                    description: restaurant.description,
                                    area: restaurant.area,
                                    style: restaurant.style,
                                  ),
                                ),
                              );
                            },
                            child: RestaurantCard(
                              id: restaurant.id,
                              name: restaurant.name,
                              imageUrl:
                                  "https://admin.maximus.works/admin/menu/${restaurant.foodItems[0].foodPhoto}",
                              rating: double.parse(restaurant.rating ?? "0.0"),
                              time: restaurant.time,
                              description: restaurant.description,
                              isFav: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ))
            : SizedBox(),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customHeading("Top Rated Restaurants"),
                SizedBox(
                  height: 6,
                ),
                SizedBox(
                  height: 245,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: foodProvider.restaurantsAbove4.length,
                    itemBuilder: (context, index) {
                      var restaurant = foodProvider.restaurantsAbove4[index];
                      return GestureDetector(
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
                                          'category': foodItem.category,
                                          'stock': foodItem.stock.toString(),
                                          'totalCount':
                                              foodItem.totalCount.toString()
                                        })
                                    .toList(),
                                rname: restaurant.name,
                                rlocation: restaurant.location,
                                food: true,
                                rid: restaurant.id.toString(),
                                isOnline: restaurant.isOnline ? 1 : 0,
                                userCoordinate: widget.location,
                                rating: restaurant.rating,
                                restrauntCoordinate: restaurant.coordinates,
                                restraurantImage: restaurant.rphoto.isNotEmpty
                                    ? 'https://admin.maximus.works/admin/restrauntimage/${restaurant.rphoto}'
                                    : 'https://admin.maximus.works/mainBanner.jpg',
                                time: restaurant.rtime,
                                description: restaurant.description,
                                area: restaurant.area,
                                style: restaurant.style,
                              ),
                            ),
                          );
                        },
                        child: RestaurantCard(
                          id: restaurant.id,
                          name: restaurant.name,
                          imageUrl:
                              "https://admin.maximus.works/admin/menu/${restaurant.foodItems[0].foodPhoto}",
                          rating: double.parse(restaurant.rating ?? "0.0"),
                          time: restaurant.time,
                          description: restaurant.description,
                          isFav: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ))
      ],
    );
  }
}

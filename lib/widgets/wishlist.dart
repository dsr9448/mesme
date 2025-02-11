import 'package:flutter/material.dart';
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

    if (foodProvider.restaurant.length == 0) {
      return Padding(
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
                                        'description': foodItem.foodDescription,
                                        'category': foodItem.category,
                                        'totalCount':
                                            foodItem.totalCount.toString()
                                      })
                                  .toList(),
                              rname: restaurant.name,
                              rlocation: restaurant.location,
                              food: true,
                              isOnline: restaurant.isOnline ? 1 : 0,
                              userCoordinate: widget.location,
                              rating: restaurant.rating,
                              restrauntCoordinate: restaurant.coordinates,
                              restraurantImage:
                                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                              time: restaurant.time,
                              description: restaurant.description,
                              area: restaurant.area,
                            ),
                          ),
                        );
                      },
                      child: RestaurantCard(
                        id: restaurant.id,
                        name: restaurant.name,
                        imageUrl:
                            "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=2020&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        rating: restaurant.rating,
                        time: restaurant.time,
                        description: restaurant.description,
                        isFav: false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ));
    } else {
      return Padding(
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
                                        'vegOrNonVeg': foodItem.vegOrNonVeg,
                                        'rating': foodItem.rating,
                                        'quantity': foodItem.Quantity,
                                        'unit': foodItem.Unit,
                                        'description': foodItem.foodDescription,
                                        'category': foodItem.category,
                                        'totalCount':
                                            foodItem.totalCount.toString()
                                      })
                                  .toList(),
                              rname: restaurant.name,
                              rlocation: restaurant.location,
                              food: true,
                              isOnline: restaurant.isOnline ? 1 : 0,
                              userCoordinate: widget.location,
                              rating: restaurant.rating,
                              restrauntCoordinate: restaurant.coordinates,
                              restraurantImage:
                                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                              time: restaurant.time,
                              description: restaurant.description,
                              area: restaurant.area,
                            ),
                          ),
                        );
                      },
                      child: RestaurantCard(
                        id: restaurant.id,
                        name: restaurant.name,
                        imageUrl:
                            "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=2020&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        rating: restaurant.rating,
                        time: restaurant.time,
                        description: restaurant.description,
                        isFav: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ));
    }
  }
}

class RestaurantCard extends StatelessWidget {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final String time;
  final String description;
  final bool isFav;

  RestaurantCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.time,
    required this.description,
    required this.isFav,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 174,
          margin: EdgeInsets.only(right: 12, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.length > 20 ? name.substring(0, 16) + "..." : name,
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text("$rating"),
                        SizedBox(width: 10),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(time),
                      ],
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        isFav
            ? Positioned(
                top: 8,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    FoodProvider().addToWishlist(id);
                  },
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}

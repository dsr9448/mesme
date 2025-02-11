import 'package:flutter/material.dart';
import 'package:mesme/provider/provider.dart';

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
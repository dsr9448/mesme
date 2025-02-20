import 'package:flutter/material.dart';
import 'package:mesme/provider/provider.dart';

class RestaurantCard extends StatefulWidget {
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
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
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
                  widget.imageUrl,
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
                      widget.name.length > 20 ? widget.name.substring(0, 16) + "..." : widget.name,
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
                        Text("${widget.rating}"),
                        SizedBox(width: 10),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(widget.time),
                      ],
                    ),
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        widget.isFav
            ? Positioned(
                top: 8,
                right: 20,
                child: GestureDetector(
                 onTap: () async {
                                                            try {
                                                             
                                                              
                                                              await  FoodProvider()
                                                                  .removeFromWishlist(
                                                                      widget.id);
                                                                          setState(() {
                                                                            
                                                                          });
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: const Text(
                                                                      'Item  Removed From  wishlist'),
                                                                  backgroundColor:
                                                                      Colors.green
                                                                          .shade800,
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                  showCloseIcon:
                                                                      true,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  closeIconColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      'Failed to remove item to wishlist'),
                                                                  backgroundColor:
                                                                      Colors.red
                                                                          .shade800,
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                  showCloseIcon:
                                                                      true,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  closeIconColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              );
                                                            }
                                                               setState(() {
                                                                            
                                                                          });
                                                       // Force UI update
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
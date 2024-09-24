import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/widgets/functionalities.dart';

class ViewItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String restaurantName;
  final String location;
  final String description;
  final bool food;
  final quantity;
  final unit;
  final isVeg;
  final rating;
  final canAdd;
  final distance;

  const ViewItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.restaurantName,
    required this.location,
    required this.description,
    required this.food,
    this.isVeg,
    this.rating,
    required this.quantity,
    required this.unit,
    this.canAdd,
    this.distance,
  });

  @override
  State<ViewItem> createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
  int quantity = 1;
  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://mesme.in/ControlHub/includes/uploads/${widget.imageUrl}',
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
              // Image.network(widget.imageUrl, fit: BoxFit.cover),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        widget.isVeg != ''
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.isVeg == 'Veg'
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    widget.food
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.table_restaurant_outlined,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.restaurantName,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      maxLines: 3,
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              widget.distance != ''
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.bike_scooter,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.distance} km away',
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      maxLines: 3,
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              widget.distance != ''
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.bike_scooter,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.distance} km away',
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                            ],
                          ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.watch_later),
                            const SizedBox(width: 12),
                            Text(
                              '30 Min',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        (widget.rating != '')
                            ? Row(
                                children: [
                                  const Icon(Icons.star),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${widget.rating}',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        Row(
                          children: [
                            Text(
                              'Qty: ',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              "${(double.parse(widget.quantity) * quantity).toString().replaceAll('.0', '')} ${widget.unit}",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹ ${widget.price.toString().replaceAll('.0', '')}',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 10,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: Colors.orange.shade700,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: [
                  // Quantity Selector
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.orange)),
                        onPressed: _decrementQuantity,
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          Text(
                            (double.parse(widget.quantity) * quantity)
                                .toString()
                                .replaceAll('.0', ''),
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.unit}  ',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.orange)),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Add to Cart Button
                  widget.canAdd == true
                      ? ElevatedButton(
                          onPressed: () {
                            FoodFunction.addToCart(
                                    widget.name,
                                    widget.price,
                                    quantity,
                                    widget.imageUrl,
                                    widget.restaurantName,
                                    widget.location,
                                    widget.food ? 'Food' : 'Grocery',
                                    context)
                                .whenComplete(() {
                              Navigator.pop(context);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          child: Text(
                            'Add to Cart ₹ ${(widget.price * quantity).toString().replaceAll('.0', '')}',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : widget.canAdd == false
                          ? ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade800,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                              ),
                              child: Text(
                                'Service Not Available',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  FoodFunction.addToCart(
                                          widget.name,
                                          widget.price,
                                          quantity,
                                          widget.imageUrl,
                                          widget.restaurantName,
                                          widget.location,
                                          widget.food ? 'Food' : 'Grocery',
                                          context)
                                      .whenComplete(() {
                                    Navigator.pop(context);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                ),
                                child: Text(
                                  'Add to Cart ₹ ${(widget.price * quantity).toString()}',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

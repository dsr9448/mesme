import 'package:flutter/material.dart';
import 'package:mesme/models/food_item.dart';
import 'package:mesme/screens/ViewItem.dart';

class HorizontalScrollWidget extends StatelessWidget {
  final List<FoodItem> items;
  final rlocation;
  final rname;

  const HorizontalScrollWidget(
      {Key? key, required this.items, this.rlocation, this.rname})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return buildFoodItemCard(items[index], context);
        },
      ),
    );
  }

  Widget buildFoodItemCard(FoodItem item, BuildContext context) {
    return Container(
      // width: 120, // Adjust the width as needed
      margin: const EdgeInsets.only(right: 8),

      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ViewItem(
                    imageUrl: item.foodPhoto,
                    name: item.foodName,
                    price: double.parse(item.price),
                    location: rlocation,
                    description: item.foodDescription,
                    restaurantName: rname,
                    isVeg: item.vegOrNonVeg,
                    rating: item.rating,
                    food: true,
                  )));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                item.foodPhoto,
                height: 100, // Adjust the height as needed
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  }
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return const SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.foodName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

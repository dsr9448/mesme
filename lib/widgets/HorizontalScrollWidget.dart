import 'package:flutter/material.dart';
import 'package:mesme/models/food_item.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HorizontalScrollWidget extends StatelessWidget {
  final List<FoodItem> items;
  final rlocation;
  final rname;
  final isOnline;
  final userCoordinate;
  final restrauntCoordinate;

  const HorizontalScrollWidget(
      {Key? key,
      required this.items,
      this.rlocation,
      this.rname,
      this.isOnline,
      this.userCoordinate,
      this.restrauntCoordinate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> result =
        isWithin6Km(userCoordinate, restrauntCoordinate);

    bool canAdd = result['distance'] <= 6 ? true : false;
    double distance = result['distance'] ?? 0.0;
    print('this is test: $result, this is test1: $canAdd');

    return SizedBox(
      height: 150, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return buildFoodItemCard(items[index], context, canAdd, distance);
        },
      ),
    );
  }

  Widget buildFoodItemCard(
      FoodItem item, BuildContext context, bool canAdd, double distance) {
    return Container(
      // width: 120, // Adjust the width as needed
      margin: const EdgeInsets.only(right: 8),

      child: GestureDetector(
        onTap: () {
          isOnline
              ? Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewItem(
                        imageUrl: item.foodPhoto,
                        name: item.foodName,
                        price: double.parse(item.price),
                        location: rlocation,
                        description: item.foodDescription,
                        quantity: item.Quantity,
                        unit: item.Unit,
                        restaurantName: rname,
                        isVeg: item.vegOrNonVeg,
                        rating: item.rating,
                        food: true,
                        canAdd: canAdd,
                        distance: distance,
                      )))
              : QuickAlert.show(
                  context: context,
                  type: QuickAlertType.info,
                  title: 'Restaurant Offline',
                  text: 'Restaurant is offline at the moment.',
                  confirmBtnText: 'Ok',
                  confirmBtnColor: Colors.orange.shade700,
                );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Stack(
                children: [
                  ColorFiltered(
                    colorFilter: isOnline
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          )
                        : const ColorFilter.mode(
                            Colors.black54,
                            BlendMode.darken,
                          ),
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://mesme.in/ControlHub/includes/uploads/${item.foodPhoto}",
                      height: 80, // Adjust the height as needed
                      width: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(
                        height: 80,
                        width: 80,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        height: 80,
                        width: 80,
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  if (!isOnline)
                    Positioned(
                      top: 8,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Offline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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

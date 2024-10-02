import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mesme/models/grocery_model.dart';
import 'package:mesme/screens/ViewItem.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HorizontalScrollGrocery extends StatelessWidget {
  final List<GroceryItem> items;
  final rlocation;
  final rname;
  final isOnline;
  final userCoordinate;
  final groceryCoordinate;

  const HorizontalScrollGrocery(
      {Key? key,
      required this.items,
      this.rlocation,
      this.rname,
      this.isOnline,
      this.userCoordinate,
      this.groceryCoordinate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> result =
        isWithin6Km(userCoordinate, groceryCoordinate);

    bool canAdd = result['distance'] <= 6 ? true : false;
    double distance = result['distance'] ?? 0.0;
    print('this is test: $result, this is test1: $canAdd');
    return SizedBox(
      height: 150, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return buildGroceryItemCard(items[index], context, canAdd, distance);
        },
      ),
    );
  }

  Widget buildGroceryItemCard(
      GroceryItem item, BuildContext context, bool canAdd, double distance) {
    return Container(
      // width: 120, // Adjust the width as needed
      margin: const EdgeInsets.only(right: 8),

      child: GestureDetector(
        onTap: () {
          isOnline == true
              ? Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewItem(
                      imageUrl: item.imageUrl,
                      name: item.name,
                      price: double.parse(item.price),
                      location: rlocation,
                      restaurantName: rname,
                      description: item.description,
                      food: false,
                      canAdd: canAdd,
                      distance: distance,
                      quantity: item.quantity,
                      unit: item.unit,
                      isVeg: '',
                      rating: '')))
              : QuickAlert.show(
                  context: context,
                  type: QuickAlertType.info,
                  title: 'Store Offline',
                  text: 'Store is offline at the moment.',
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
                    colorFilter: isOnline == true
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
                          'https://mesme.in/ControlHub/includes/uploads/${item.imageUrl}',
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
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  if (isOnline == false)
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
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(50),
            //   child: Image.network(
            //     'https://mesme.in/ControlHub/includes/uploads/${item.imageUrl}',
            //     height: 100, // Adjust the height as needed
            //     width: 100,
            //     fit: BoxFit.cover,
            //     loadingBuilder: (BuildContext context, Widget child,
            //         ImageChunkEvent? loadingProgress) {
            //       if (loadingProgress == null) {
            //         return child;
            //       } else {
            //         return SizedBox(
            //           height: 100,
            //           width: 100,
            //           child: Center(
            //             child: CircularProgressIndicator(
            //               color: Colors.black,
            //               value: loadingProgress.expectedTotalBytes != null
            //                   ? loadingProgress.cumulativeBytesLoaded /
            //                       (loadingProgress.expectedTotalBytes ?? 1)
            //                   : null,
            //             ),
            //           ),
            //         );
            //       }
            //     },
            //     errorBuilder: (BuildContext context, Object error,
            //         StackTrace? stackTrace) {
            //       return const SizedBox(
            //         height: 100,
            //         width: 100,
            //         child: Center(
            //           child: Icon(Icons.error, color: Colors.red),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.name,
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

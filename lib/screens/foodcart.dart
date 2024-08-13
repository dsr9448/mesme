import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/services/api_service.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FoodCart extends StatefulWidget {
  const FoodCart({super.key});

  @override
  _FoodCartState createState() => _FoodCartState();
}

class _FoodCartState extends State<FoodCart> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsString = prefs.getStringList('cartItems') ?? [];
    setState(() {
      cartItems = cartItemsString.map((item) {
        Map<String, dynamic> decodedItem =
            jsonDecode(item) as Map<String, dynamic>;
        decodedItem['price'] = double.parse(
            decodedItem['price'].toString()); // Ensure price is a double
        return decodedItem;
      }).toList();
    });
  }

  Future<void> _clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    FoodFunction.updateCartItemCount(0);
    setState(() {
      cartItems.clear();
    });
  }

  Future<void> _updateCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsString =
        cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('cartItems', cartItemsString);
    FoodFunction.updateCartItemCount(-1);
  }

  void _increaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        cartItems[index]['quantity']++;
      });
      _updateCartItems();
    }
  }

  void _decreaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        if (cartItems[index]['quantity'] > 1) {
          cartItems[index]['quantity']--;
        }
      });
      _updateCartItems();
    }
  }

  double _calculateGSTAndServiceCharge(double totalAmount) {
    if (totalAmount >= 0 && totalAmount <= 200) {
      return 25;
    } else if (totalAmount <= 300) {
      return 35;
    } else if (totalAmount <= 400) {
      return 45;
    } else {
      // For amounts greater than 400, increase by 25 for every additional 100
      int extraRange = ((totalAmount - 400) / 100).ceil();
      return 45 + (extraRange * 10);
    }
  }

  void _removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        cartItems.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Item removed from cart",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.black,
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
      _updateCartItems();
    }
  }

  double _calculateTotalAmount() {
    return cartItems.fold(
        0, (total, item) => total + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;
    // Group items by restaurant name
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in cartItems) {
      if (groupedItems.containsKey(item['restaurantName'])) {
        groupedItems[item['restaurantName']]!.add(item);
      } else {
        groupedItems[item['restaurantName']] = [item];
      }
    }
    double totalAmount = _calculateTotalAmount();
    double gstAndServiceCharge = _calculateGSTAndServiceCharge(totalAmount);
    double amountPayable = totalAmount + gstAndServiceCharge;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50)),
                  child: GestureDetector(
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MeLocation(
                                uid: userData?.id ?? '-',
                              )),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Location',
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                  color: Colors.black, fontSize: 12))),
                      Text(
                          userData?.address != null
                              ? userData!.address.split(' ').take(1).join(' ') +
                                  (userData!.address.split(' ').length > 2
                                      ? '.'
                                      : 'Enter location')
                              : 'Enter location',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              'Cart',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            ),
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.black12)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: cartItems.isEmpty
            ? const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 100, color: Colors.black12),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Cart is empty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Looks like you haven\'t added anything to your cart yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: groupedItems.keys.length,
                      itemBuilder: (context, groupIndex) {
                        String restaurantName =
                            groupedItems.keys.elementAt(groupIndex);
                        List<Map<String, dynamic>> items =
                            groupedItems[restaurantName]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.white,
                              child: Text(
                                restaurantName,
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...items.map((item) {
                              int itemIndex = cartItems.indexOf(item);
                              return Dismissible(
                                key: Key(item['name']),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  _removeItem(itemIndex);
                                },
                                background: Container(
                                  color: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    // border: Border.fromBorderSide(side),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item['imageUrl'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Location: ${item['location']}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              '₹${item['price'].toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                style: const ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll(
                                                            Colors.black)),
                                                onPressed: () =>
                                                    _decreaseQuantity(
                                                        itemIndex),
                                                icon: const Icon(Icons.remove,
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                '${item['quantity']}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              IconButton(
                                                style: const ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll(
                                                            Colors.black)),
                                                onPressed: () =>
                                                    _increaseQuantity(
                                                        itemIndex),
                                                icon: const Icon(Icons.add,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            style: const ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Color.fromARGB(
                                                            255, 206, 40, 28))),
                                            onPressed: () =>
                                                _removeItem(itemIndex),
                                            icon: const Icon(Icons.delete,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const Divider()
                          ],
                        );
                      },
                    ),
                  ),
                  cartItems.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.black45),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Cart Summary',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount : ',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹ ${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'GST & Service Charges : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹  ${gstAndServiceCharge.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery Charges : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Free',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Other Charges : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Nil',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Amount Payable: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '₹${amountPayable.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  const SizedBox(
                    height: 18,
                  ),
                  cartItems.isNotEmpty
                      ? GestureDetector(
                          onTap: () async {
                            // Confirm the order creation
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              text: 'Confirm and place your order?',
                              confirmBtnText: 'Yes',
                              cancelBtnText: 'No',
                              confirmBtnColor: Colors.green.shade600,
                              onConfirmBtnTap: () async {
                                Navigator.of(context).pop();
                                UserModel? userData = Provider.of<FoodProvider>(
                                        context,
                                        listen: false)
                                    .userData;
                                if (userData == null) {
                                  // Handle case where user data is not available
                                  return;
                                }

                                // Call the createOrder function
                                await ApiService()
                                    .createOrder(
                                  userData.id,
                                  'Order Placed',
                                  userData.address,
                                  amountPayable, // Your calculated total price
                                  cartItems.map((item) {
                                    return {
                                      'category': item['restaurantName'] != ''
                                          ? item['restaurantName']
                                          : item['category'],
                                      'itemName': item['name'],
                                      'qty': item['quantity'],
                                      'price': item['price'],
                                    };
                                  }).toList(),
                                )
                                    .whenComplete(() {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    text: 'Order placed successfully',
                                    title: 'Thank you for your order!',
                                    confirmBtnColor: Colors.black,
                                    onConfirmBtnTap: () async {
                                      await Provider.of<FoodProvider>(context,
                                              listen: false)
                                          .fetchOrders();
                                      Navigator.pop(context);
                                    },
                                  );
                                  _clearCart();
                                });
                              },
                            );
                          },  
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Text(
                              'Place Order',
                              textAlign: TextAlign
                                  .center, // Display total amount as a double
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
      ),
    );
  }
}

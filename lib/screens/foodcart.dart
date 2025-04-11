import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/widgets/functionalities.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    } else if (totalAmount >= 201 && totalAmount <= 300) {
      return 35;
    } else if (totalAmount >= 301 && totalAmount <= 400) {
      return 45;
    } else if (totalAmount >= 401 && totalAmount <= 500) {
      return 55;
    } else if (totalAmount >= 501 && totalAmount <= 600) {
      return 65;
    } else if (totalAmount >= 601 && totalAmount <= 700) {
      return 75;
    } else if (totalAmount >= 701 && totalAmount <= 800) {
      return 85;
    } else if (totalAmount >= 801 && totalAmount <= 900) {
      return 95;
    } else if (totalAmount >= 901 && totalAmount <= 1000) {
      return 105;
    } else if (totalAmount >= 1001 && totalAmount <= 1100) {
      return 115;
    } else {
      int extraRange = ((totalAmount - 1100) / 100).ceil();
      return 115 + (extraRange * 10);
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
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

  double _calculateServiceCharge(double totalAmount) {
    if (totalAmount >= 1 && totalAmount <= 250) {
      return 15 + (15 * 0.18);
    } else if (totalAmount >= 251 && totalAmount <= 500) {
      return 20 + (20 * 0.18);
    } else if (totalAmount >= 501 && totalAmount <= 750) {
      return 25 + (25 * 0.18);
    } else {
      int extraRange = ((totalAmount - 750) / 250).ceil();
      return 25 + (extraRange * 5) + (25 * 0.18);
    }
  }

  double _calculateDeliveryCharge(double distance) {
    // This is a placeholder - you'll need to implement actual distance calculation
    if (distance <= 3) {
      return 30 + (30 * 0.05);
    } else if (distance <= 3.5) {
      return 35 + (35 * 0.05);
    } else {
      return 49 + (49 * 0.05);
    }
  }

  double _calculateGST(double amount) {
    return amount * 0.05; // 5% GST
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    UserModel? userData = foodProvider.userData;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURE CHECKOUT',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${cartItems.length} Items',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 140,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Good food is always cooking! Go ahead, order some yummy items from the menu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'BROWSE RESTAURANTS',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Delivery Address Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.orange[700], size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delivery Address',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userData?.address ?? 'Add delivery address',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Cart Items Section
                        Container(
                          color: Colors.white,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedItems.keys.length,
                            itemBuilder: (context, groupIndex) {
                              String restaurantName =
                                  groupedItems.keys.elementAt(groupIndex);
                              List<Map<String, dynamic>> items =
                                  groupedItems[restaurantName]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.store,
                                            color: Colors.orange[700]),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            restaurantName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...items.map((item) {
                                    int itemIndex = cartItems.indexOf(item);
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]!),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.circle,
                                              size: 12,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item['name'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '₹${item['price'].toString().replaceAll('.0', '')}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          _removeItem(
                                                              itemIndex);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8),
                                                          child: Icon(
                                                            Icons.delete,
                                                            size: 16,
                                                            color: Colors
                                                                .red.shade600,
                                                          ),
                                                        ))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey[300]!),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () =>
                                                      _decreaseQuantity(
                                                          itemIndex),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    alignment: Alignment.center,
                                                    child: Icon(Icons.remove,
                                                        size: 18,
                                                        color:
                                                            Colors.orange[700]),
                                                  ),
                                                ),
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      left: BorderSide(
                                                          color: Colors
                                                              .grey[300]!),
                                                      right: BorderSide(
                                                          color: Colors
                                                              .grey[300]!),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${item['quantity']}',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () =>
                                                      _increaseQuantity(
                                                          itemIndex),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    alignment: Alignment.center,
                                                    child: Icon(Icons.add,
                                                        size: 18,
                                                        color:
                                                            Colors.orange[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ),

                        // Cart Summary Section
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cart Summary',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Bill Details',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.close),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                              const SizedBox(height: 12),

                                              // Item Total
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Price',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${totalAmount.toStringAsFixed(2)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // GST
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'GST (5%)',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${_calculateGST(totalAmount).toStringAsFixed(2)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Service Charge
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Service Charge',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.info_outline,
                                                            size: 16),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: Text(
                                                                'Service Charge Details',
                                                                style: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                              content: Text(
                                                                '₹15 for orders between ₹1-250\n'
                                                                '₹20 for orders between ₹251-500\n'
                                                                '₹25 for orders between ₹501-750\n'
                                                                '+₹5 for each additional ₹250',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child:
                                                                      const Text(
                                                                          'OK'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        color: Colors.grey[600],
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '₹${_calculateServiceCharge(totalAmount).toStringAsFixed(2)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Delivery Charge
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Delivery Charge ( ${cartItems[0]['distance']} Km)',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.info_outline,
                                                            size: 16),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: Text(
                                                                'Delivery Charge Details',
                                                                style: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                              content: Text(
                                                                '₹30 for 1-3 km\n'
                                                                '₹35 for 3.5 km\n'
                                                                '₹49 for 4.9 km',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child:
                                                                      const Text(
                                                                          'OK'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        color: Colors.grey[600],
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '₹${_calculateDeliveryCharge(3.0).toStringAsFixed(2)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                child: Divider(thickness: 1),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Amount',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${(totalAmount + _calculateGST(totalAmount) + _calculateServiceCharge(totalAmount) + _calculateDeliveryCharge(3.0)).toStringAsFixed(2)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.orange[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.info_outline,
                                        color: Colors.orange, size: 20),
                                    label: Text(
                                      'View Breakup',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 12),

                              // Default view - Only show item total and final amount
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Item Total',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '₹${totalAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(thickness: 1),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount Payable',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '₹${(totalAmount + _calculateGST(totalAmount) + _calculateServiceCharge(totalAmount) + _calculateDeliveryCharge(3.0)).toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Payment Button
                if (cartItems.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: ElevatedButton(
                        onPressed: () async {
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
                                return;
                              }

                              // Show loading dialog
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.loading,
                                text: 'Placing your order...',
                                showConfirmBtn: false,
                              );

                              try {
                                final result = await Provider.of<FoodProvider>(
                                        context,
                                        listen: false)
                                    .createOrder(
                                  userData.id,
                                  cartItems[0]['rid'],
                                  'Order Placed',
                                  userData.address,
                                  amountPayable,
                                  cartItems.map((item) {
                                    return {
                                      'category': item['category'],
                                      'itemName': item['name'],
                                      'qty': item['quantity'],
                                      'price': item['price'],
                                    };
                                  }).toList(),
                                );

                                // Close loading dialog
                                Navigator.of(context).pop();

                                if (result['success'] == true) {
                                  // Show success dialog
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    text: 'Order #${result['orderId']} placed successfully',
                                    title: 'Thank you for your order!',
                                    confirmBtnColor: Colors.orange.shade700,
                                    onConfirmBtnTap: () async {
                                      Navigator.of(context).pop();
                                      await Provider.of<FoodProvider>(context,
                                              listen: false)
                                          .fetchOrders();
                                      Navigator.pop(context);
                                    },
                                  );
                                  _clearCart();
                                } else {
                                  // Show error dialog
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    text: result['message'] ?? 'Failed to place order',
                                    title: 'Order Failed',
                                    confirmBtnColor: Colors.red,
                                    onConfirmBtnTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }
                              } catch (e) {
                                // Close loading dialog
                                Navigator.of(context).pop();

                                // Show error dialog
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  text: 'An unexpected error occurred. Please try again.',
                                  title: 'Error',
                                  confirmBtnColor: Colors.red,
                                  onConfirmBtnTap: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'PLACE ORDER',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

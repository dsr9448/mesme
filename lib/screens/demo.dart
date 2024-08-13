// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Order {
//   final String orderId;
//   final String orderDate;
//   final double totalPrice;
//   final double rating;
//   final String status;
//   final String? deliveryPartnerName;
//   final String? deliveryPartnerPhone;

//   Order({
//     required this.orderId,
//     required this.orderDate,
//     required this.totalPrice,
//     required this.rating,
//     required this.status,
//     this.deliveryPartnerName,
//     this.deliveryPartnerPhone,
//   });
// }

// class OrderListPage extends StatefulWidget {
//   @override
//   _OrderListPageState createState() => _OrderListPageState();
// }

// class _OrderListPageState extends State<OrderListPage> {
//   final List<Order> orders = [
//     Order(
//       orderId: '12345',
//       orderDate: '2024-07-29',
//       totalPrice: 120.5,
//       rating: 4.5,
//       status: 'Accepted',
//       deliveryPartnerName: 'John Doe',
//       deliveryPartnerPhone: '123-456-7890',
//     ),
//     Order(
//       orderId: '98765',
//       orderDate: '2024-07-28',
//       totalPrice: 89.9,
//       rating: 4.0,
//       status: 'Delivered',
//     ),
//     Order(
//       orderId: '56789',
//       orderDate: '2024-07-27',
//       totalPrice: 45.0,
//       rating: 3.8,
//       status: 'Preparing',
//     ),
//     Order(
//       orderId: '96789',
//       orderDate: '2024-07-27',
//       totalPrice: 45.0,
//       rating: 3.8,
//       status: 'Order Placed',
//     ),
//   ];

//   List<Order> filteredOrders = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredOrders = orders;
//   }

//   void _filterOrders(String query) {
//     final filtered = orders.where((order) {
//       final orderIdLower = order.orderId.toLowerCase();
//       final orderDateLower = order.orderDate.toLowerCase();
//       final searchLower = query.toLowerCase();

//       return orderIdLower.contains(searchLower) ||
//           orderDateLower.contains(searchLower);
//     }).toList();

//     setState(() {
//       filteredOrders = filtered;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         forceMaterialTransparency: true,
//         title: TextField(
//           cursorColor: Colors.black,
//           decoration: const InputDecoration(
//             hintText: 'Search Orders...',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(borderSide: BorderSide.none),
//           ),
//           onChanged: _filterOrders,
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.pushNamed(context, '/FoodProfile');
//             },
//             icon: const Icon(
//               Icons.person,
//               color: Colors.white,
//             ),
//             style: const ButtonStyle(
//                 backgroundColor: WidgetStatePropertyAll(Colors.black)),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           const Text(
//             'Orders History',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredOrders.length,
//               itemBuilder: (context, index) {
//                 final order = filteredOrders[index];
//                 return ListTile(
//                   title: Row(
//                     children: [
//                       const Text(
//                         'Order No:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(
//                         width: 8,
//                       ),
//                       Text(order.orderId),
//                     ],
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Text(
//                             'Status:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(
//                             width: 8,
//                           ),
//                           Text(
//                             order.status,
//                             style: TextStyle(
//                               color: order.status == 'Order Placed'
//                                   ? Colors.lightBlue
//                                   : order.status == 'Cancelled'
//                                       ? Colors.red
//                                       : order.status == 'Accepted'
//                                           ? Colors.blue
//                                           : order.status == 'Preparing'
//                                               ? Colors.orange
//                                               : order.status ==
//                                                       'Ready for Pickup'
//                                                   ? Colors.yellow
//                                                   : order.status == 'On the Way'
//                                                       ? Colors.green
//                                                       : order.status ==
//                                                               'Delivered'
//                                                           ? Colors.deepPurple
//                                                           : Colors
//                                                               .black, // default color if no match
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 8,
//                       ),
//                       order.status == 'Order Placed'
//                           ? GestureDetector(
//                               onTap: () {},
//                               child: Container(
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade800,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: const Text(
//                                     'Cancel Order',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600),
//                                   )),
//                             )
//                           : const SizedBox(),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => OrderDetailPage(order: order),
//                         ),
//                       );
//                     },
//                     style: const ButtonStyle(
//                         backgroundColor: WidgetStatePropertyAll(Colors.black)),
//                     icon: const Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => OrderDetailPage(order: order),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OrderDetailPage extends StatelessWidget {
//   final Order order;

//   OrderDetailPage({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         forceMaterialTransparency: true,
//         leading: IconButton(
//           style: const ButtonStyle(
//               backgroundColor: WidgetStatePropertyAll(Colors.black)),
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         centerTitle: true,
//         title: Text('Order Details of ${order.orderId}'),
//       ),
//       body: OrderContent(order: order),
//     );
//   }
// }

// class OrderContent extends StatelessWidget {
//   final Order order;

//   OrderContent({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     // Mock data for item availability
//     final List<bool> itemAvailability = [true, true, false, true, false];
//     final double availableItemsTotal =
//         _calculateAvailableItemsTotal(itemAvailability);

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Column(
//                       children: [
//                         const Text(
//                           'Date: ',
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black54,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           order.orderDate,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Column(
//                       children: [
//                         const Text(
//                           'Total Price:',
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black54,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '₹${order.totalPrice}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 8.0),
//                     child: Row(
//                       children: [
//                         Column(
//                           children: [
//                             const Text(
//                               'Rating:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                             Text(
//                               '${order.rating}',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         // const SizedBox(width: 8),
//                         // Icon(
//                         //   Icons.star,
//                         //   color: Colors.yellow[700],
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'Delivery Status',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           CreativeDeliveryStatus(status: order.status),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           if (order.status == 'Accepted' && order.deliveryPartnerName != null)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Text(
//                             'Delivery Partner :',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(
//                             width: 8,
//                           ),
//                           Text(
//                             order.deliveryPartnerName!,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           launch('tel:${order.deliveryPartnerPhone}');
//                         },
//                         icon: const Icon(
//                           Icons.phone,
//                           color: Colors.white,
//                         ),
//                         style: const ButtonStyle(
//                             backgroundColor:
//                                 WidgetStatePropertyAll(Colors.black)),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           OrderDetailsSection(
//             sectionTitle: 'Grocery Items',
//             items: [
//               OrderDetailsCategory(
//                 category: 'Fruits & Vegetables',
//                 items: [
//                   OrderItem(
//                       name: 'Apples',
//                       quantity: 5,
//                       price: 100,
//                       isAvailable: true),
//                   OrderItem(
//                       name: 'Bananas',
//                       quantity: 6,
//                       price: 200,
//                       isAvailable: true),
//                   OrderItem(
//                       name: 'Carrots',
//                       quantity: 2,
//                       price: 50,
//                       isAvailable: false),
//                 ],
//               ),
//               OrderDetailsCategory(
//                 category: 'Dairy & Eggs',
//                 items: [
//                   OrderItem(
//                       name: 'Milk', quantity: 2, price: 48, isAvailable: true),
//                   OrderItem(
//                       name: 'Cheese',
//                       quantity: 200,
//                       price: 162,
//                       isAvailable: false),
//                 ],
//               ),
//             ],
//           ),
//           Container(
//             margin: const EdgeInsets.all(6),
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//             width: double.infinity,
//             decoration: BoxDecoration(
//                 color: Colors.black,
//                 // border: Border.all(color: Colors.black87, width: 1.0),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Order Summary',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Total Amount : ',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         '₹ ${availableItemsTotal.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'GST & Service Charges : ',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         '₹ 85',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Delivery Charges : ',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         'Free',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Other Charges : ',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         'Nil',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Amount Payable: ',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(
//                         '₹${availableItemsTotal + 85.0}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8)),
//                     child: const Text(
//                       'Pay Now',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _calculateAvailableItemsTotal(List<bool> availability) {
//     // Mock calculation; adjust based on your actual items and prices
//     final List<double> itemPrices = [100.0, 50.0, 30.0, 70.0, 20.0];
//     double total = 0.0;

//     for (int i = 0; i < availability.length; i++) {
//       if (availability[i]) {
//         total += itemPrices[i];
//       }
//     }

//     return total;
//   }
// }

// class OrderDetailsSection extends StatelessWidget {
//   final String sectionTitle;
//   final List<OrderDetailsCategory> items;

//   OrderDetailsSection({required this.sectionTitle, required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             sectionTitle,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           Column(
//             children:
//                 items.map((item) => OrderDetailsItem(item: item)).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OrderDetailsCategory {
//   final String category;
//   final List<OrderItem> items;

//   OrderDetailsCategory({required this.category, required this.items});
// }

// class OrderItem {
//   final String name;
//   final int quantity;
//   final double price;
//   final bool isAvailable;

//   OrderItem(
//       {required this.name,
//       required this.quantity,
//       required this.price,
//       required this.isAvailable});
// }

// class OrderDetailsItem extends StatelessWidget {
//   final OrderDetailsCategory item;

//   OrderDetailsItem({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             item.category,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: item.items.asMap().entries.map((entry) {
//               int index = entry.key + 1; // Numbering starts from 1
//               OrderItem orderItem = entry.value;

//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: Row(
//                         children: [
//                           Text(
//                             '$index. ',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           Text(
//                             '${orderItem.name} - ${orderItem.quantity}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Text(
//                         '₹ ${orderItem.price.toString()}',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black,
//                         ),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         orderItem.isAvailable ? "Accepted" : "(Unavailable)",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: orderItem.isAvailable
//                               ? Colors.green.shade900
//                               : Colors.red.shade800,
//                         ),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           )
//         ],
//       ),
//     );
//   }
// }

// class CreativeDeliveryStatus extends StatelessWidget {
//   final String status;

//   CreativeDeliveryStatus({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Current Status: $status',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Column(
//             children: [
//               StatusIndicator(
//                 label: 'Order Placed',
//                 isActive: _getStatusLevel(status) >= 1,
//                 isCurrent: status == 'Order Placed',
//               ),
//               StatusIndicator(
//                 label: 'Accepted',
//                 isActive: _getStatusLevel(status) >= 2,
//                 isCurrent: status == 'Accepted',
//               ),
//               StatusIndicator(
//                 label: 'Preparing',
//                 isActive: _getStatusLevel(status) >= 3,
//                 isCurrent: status == 'Preparing',
//               ),
//               StatusIndicator(
//                 label: 'Picked up',
//                 isActive: _getStatusLevel(status) >= 4,
//                 isCurrent: status == 'Picked up',
//               ),
//               StatusIndicator(
//                 label: 'In Transit',
//                 isActive: _getStatusLevel(status) >= 5,
//                 isCurrent: status == 'In Transit',
//               ),
//               StatusIndicator(
//                 label: 'Delivered',
//                 isActive: _getStatusLevel(status) >= 6,
//                 isCurrent: status == 'Delivered',
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             getEstimatedArrival(status),
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   int _getStatusLevel(String status) {
//     switch (status) {
//       case 'Preparing':
//         return 1;
//       case 'Picked up':
//         return 2;
//       case 'In Transit':
//         return 3;
//       case 'Delivered':
//         return 4;
//       default:
//         return 0;
//     }
//   }

//   String getEstimatedArrival(String status) {
//     switch (status) {
//       case 'Preparing':
//         return 'Estimated Arrival: 2 hours';
//       case 'Picked up':
//         return 'Estimated Arrival: 1.5 hours';
//       case 'In Transit':
//         return 'Estimated Arrival: 1 hour';
//       case 'Delivered':
//         return 'Delivered';
//       default:
//         return 'Status Unknown';
//     }
//   }
// }

// class StatusIndicator extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final bool isCurrent;

//   StatusIndicator({
//     required this.label,
//     required this.isActive,
//     required this.isCurrent,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             Container(
//               width: 12,
//               height: 12,
//               decoration: BoxDecoration(
//                 color: isActive
//                     ? (isCurrent ? Colors.blue : Colors.green)
//                     : Colors.grey,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             Container(
//               width: 2,
//               height: 40,
//               color: isActive ? Colors.green : Colors.grey,
//             ),
//           ],
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//               color: isCurrent ? Colors.blue : Colors.black54,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

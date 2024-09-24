import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mesme/models/ordermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<Order> filteredOrders = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _searchController.addListener(() {
      _filterOrders(_searchController.text);
    });
  }

  void _fetchOrders() async {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    await foodProvider.fetchOrders();
    setState(() {
      filteredOrders = foodProvider.orders;
    });
  }

  void _cancelOrder(String orderId) async {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    try {
      // Cancel the order via API
      await ApiService().updateFoodOrder(orderId, 'Cancelled');

      // Refetch the orders from the server
      await foodProvider.fetchOrders();

      // Update the UI
      setState(() {
        filteredOrders = foodProvider.orders; // Update filteredOrders list
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order was cancelled successfully'),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          closeIconColor: Colors.white,
        ),
      );
    } catch (e) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          closeIconColor: Colors.white,
        ),
      );
    }
  }

  void _updateRating(String orderId, double rating) async {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    try {
      // Cancel the order via API
      await ApiService().updateOrderRating(orderId, rating.toString());

      // Refetch the orders from the server
      await foodProvider.fetchOrders();

      // Update the UI
      setState(() {
        filteredOrders = foodProvider.orders; // Update filteredOrders list
      });
      // Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for your rating!'),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          closeIconColor: Colors.white,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to upate rating'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          closeIconColor: Colors.white,
        ),
      );
    }
  }

  void _updatePayment(String orderId, String status) async {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    try {
      // Cancel the order via API
      await ApiService().updatePayment(orderId, status);

      // Refetch the orders from the server
      await foodProvider.fetchOrders();

      // Update the UI
      setState(() {
        filteredOrders = foodProvider.orders; // Update filteredOrders list
      });
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Transaction Completed Successfully!',
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Sorry, something went wrong',
      );
    }
  }

  void _filterOrders(String query) {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    setState(() {
      filteredOrders = foodProvider.orders.where((order) {
        final orderIdLower = order.orderId.toLowerCase();
        final orderDateLower = order.orderDate.toLowerCase();
        final searchLower = query.toLowerCase();

        return orderIdLower.contains(searchLower) ||
            orderDateLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    filteredOrders =
        filteredOrders.isEmpty ? foodProvider.orders : filteredOrders;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        title: TextField(
          controller: _searchController,
          onChanged: _filterOrders,
          cursorColor: Colors.orange.shade700,
          decoration: const InputDecoration(
            hintText: 'Search Orders...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/FoodProfile');
            },
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          ),
        ],
      ),
      body: filteredOrders.isEmpty
          ? const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 100, color: Colors.black12),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'No Orders Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'It seems you haven\'t placed any orders yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const Text(
                  'Orders History',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // How much the shadow spreads
                              blurRadius: 6, // Blur effect
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: ListTile(
                          style: ListTileStyle.list,
                          title: Row(
                            children: [
                              const Text(
                                'Order No:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(order.orderId),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Status:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.status,
                                    style: TextStyle(
                                      color: _statusColor(order.status),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              order.status == 'Delivered' && order.rating == '0'
                                  ? Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating:
                                              double.parse(order.rating),
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemSize: 28,
                                          itemCount: 5,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0.0),
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          updateOnDrag: true,
                                          onRatingUpdate: (rating) {
                                            // _updateRating(order.orderId, rating);
                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              _updateRating(
                                                  order.orderId, rating);
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              if (order.status == 'Order Placed')
                                GestureDetector(
                                  onTap: () {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.confirm,
                                        text:
                                            'Do you want to cancel your order?',
                                        title:
                                            'Confirm Cancellation ${order.orderId}',
                                        backgroundColor: Colors.white,
                                        confirmBtnText: 'Yes',
                                        cancelBtnText: 'No',
                                        confirmBtnColor: Colors.red.shade800,
                                        onConfirmBtnTap: () async {
                                          _cancelOrder(order.orderId);
                                        });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade800,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Cancel Order',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailPage(order: order),
                                ),
                              ).whenComplete(() {
                                _fetchOrders();
                              });
                            },
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.orange)),
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailPage(order: order),
                              ),
                            ).whenComplete(() {
                              _fetchOrders();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Order Placed':
        return Colors.blue.shade900;
      case 'Cancelled':
        return Colors.red.shade800;
      case 'Accepted':
        return Colors.blueAccent.shade700;
      case 'Preparing':
        return Colors.orange.shade900;
      case 'Ready for Pickup':
        return Colors.yellow.shade600;
      case 'On the Way':
        return Colors.deepPurple.shade800;
      case 'Delivered':
        return Colors.green.shade800;
      default:
        return Colors.black;
    }
  }
}

class OrderDetailPage extends StatelessWidget {
  final Order order;

  OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('Order Details of ${order.orderId}'),
      ),
      body: OrderContent(order: order),
    );
  }
}

class OrderContent extends StatelessWidget {
  final Order order;

  OrderContent({required this.order});

  @override
  Widget build(BuildContext context) {
    double price = 0.0;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Date ',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                order.orderDate.substring(0, 10),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${(order.totalPrice).toString().replaceAll('.00', '')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    order.status == 'Delivered'
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'Rating',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          order.rating,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                if (order.status == 'Accepted' &&
                    order.deliveryPartnerName != null)
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Text(
                        '${order.deliveryPartnerName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          launch('tel:${order.deliveryPartnerPhone}');
                        },
                        icon: const Icon(Icons.phone),
                        color: Colors.white,
                        style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.orange),
                        ),
                      ),
                    ],
                  ),
                Divider(thickness: 1, color: Colors.grey[300]),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Delivery Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                (order.status == 'Cancelled')
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.status,
                              style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The order has been cancelled',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      )
                    : CreativeDeliveryStatus(status: order.status),
                Divider(thickness: 1, color: Colors.grey[300]),
                const SizedBox(height: 16),
                ...order.categories.entries.map((entry) {
                  String category = entry.key;
                  List<OrderCategory> items = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.asMap().entries.map((entry) {
                            int index = entry.key;
                            OrderCategory item = entry.value;
                            price = price +
                                double.parse(
                                    (item.quantity * item.price).toString());
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Text(
                                          '${index + 1}. ${item.name} - ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '₹ ${(item.quantity * item.price).toString().replaceAll('.0', '')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      order.status == 'Cancelled'
                                          ? "Cancelled"
                                          : item.isAvailable == 0
                                              ? "Waiting"
                                              : item.isAvailable == 1
                                                  ? "Accepted"
                                                  : "(Unavailable)",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: order.status == 'Cancelled'
                                            ? Colors.red.shade800
                                            : item.isAvailable == 1
                                                ? Colors.green.shade900
                                                : Colors.red.shade800,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                (order.status != 'Cancelled')
                    ? Container(
                        // margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            // border: Border.all(color: Colors.black87, width: 1.0),
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹ ${price.toString().replaceAll('.0', '')}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹ ${(double.parse(order.totalPrice) - price).toString().replaceAll('.0', '')}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Free',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Nil',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                  order.status == 'Delivered' &&
                                              order.paymentStatus ==
                                                  'Pending' ||
                                          order.paymentStatus == 'Failed'
                                      ? const Text(
                                          'Amount Payable: ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : order.paymentStatus == 'Pending'
                                          ? const Text(
                                              'Amount Payable: ',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Amount Paid: ',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                  Text(
                                    '₹ ${double.parse(order.totalPrice).toString().replaceAll('.0', '')}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              order.status == 'Delivered' &&
                                          order.paymentStatus == 'Pending' ||
                                      order.paymentStatus == 'Failed'
                                  ? GestureDetector(
                                      onTap: () {
                                        Provider.of<FoodProvider>(context,
                                                listen: false)
                                            .openCheckout(
                                                double.parse(order.totalPrice),
                                                '${order.orderId} ${order.orderDate}',
                                                order.orderId)
                                            .whenComplete(() {
                                          QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.success,
                                              title: 'Payment Successful',
                                              confirmBtnColor:
                                                  Colors.orange.shade700,
                                              text:
                                                  'Transaction Completed Successfully!',
                                              onConfirmBtnTap: () {
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        '/home',
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              });
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: const Text(
                                          'Pay Now',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Order Placed':
        return Colors.lightBlue;
      case 'Cancelled':
        return Colors.red;
      case 'Accepted':
        return Colors.blue;
      case 'Preparing':
        return Colors.orange;
      case 'Ready for Pickup':
        return Colors.yellow;
      case 'On the Way':
        return Colors.green;
      case 'Delivered':
        return Colors.deepPurple;
      default:
        return Colors.black;
    }
  }
}

class OrderDetailsSection extends StatelessWidget {
  final List<OrderCategory> orders;
  final String status;
  double price = 0.0;
  OrderDetailsSection({required this.orders, required this.status});

  @override
  Widget build(BuildContext context) {
    // Group orders by category
    Map<String, List<OrderCategory>> categorizedOrders = {};
    for (var order in orders) {
      if (categorizedOrders.containsKey(order.category)) {
        categorizedOrders[order.category]!.add(order);
      } else {
        categorizedOrders[order.category] = [order];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categorizedOrders.keys.map((category) {
        List<OrderCategory> items = categorizedOrders[category]!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.asMap().entries.map((entry) {
                  int index = entry.key;
                  OrderCategory item = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}. ${item.name} - ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '₹ ${item.quantity * item.price.toDouble()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            status == 'Cancelled'
                                ? "Cancelled"
                                : item.isAvailable == 0
                                    ? "Waiting"
                                    : item.isAvailable == 1
                                        ? "Accepted"
                                        : "Unavailable",
                            style: TextStyle(
                              fontSize: 14,
                              color: status == 'Cancelled'
                                  ? Colors.red.shade800
                                  : item.isAvailable == 1
                                      ? Colors.green.shade900
                                      : Colors.red.shade800,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CreativeDeliveryStatus extends StatelessWidget {
  final String status;

  CreativeDeliveryStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              StatusIndicator(
                label: 'Order Placed',
                isActive: _getStatusLevel(status) >= 1,
                isCurrent: status == 'Order Placed',
              ),
              StatusIndicator(
                label: 'Accepted',
                isActive: _getStatusLevel(status) >= 2,
                isCurrent: status == 'Accepted',
              ),
              StatusIndicator(
                label: 'Preparing',
                isActive: _getStatusLevel(status) >= 3,
                isCurrent: status == 'Preparing',
              ),
              StatusIndicator(
                label: 'Picked up',
                isActive: _getStatusLevel(status) >= 4,
                isCurrent: status == 'Picked up',
              ),
              StatusIndicator(
                label: 'On The Way',
                isActive: _getStatusLevel(status) >= 5,
                isCurrent: status == 'On The Way',
              ),
              StatusIndicator(
                label: 'Delivered',
                isActive: _getStatusLevel(status) >= 6,
                isCurrent: status == 'Delivered',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            getEstimatedArrival(status),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  int _getStatusLevel(String status) {
    switch (status) {
      case 'Preparing':
        return 1;
      case 'Picked up':
        return 2;
      case 'On The Way':
        return 3;
      case 'Delivered':
        return 4;
      default:
        return 0;
    }
  }

  String getEstimatedArrival(String status) {
    switch (status) {
      case 'Order Placed':
        return 'Order was placed Successfully';
      case 'Accepted':
        return 'Order was Accepted By the Delivery Partner';
      case 'Preparing':
        return 'Your order is being prepared';
      case 'Picked up':
        return 'Your order has been Picked up by the Delivery Partner';
      case 'On The Way':
        return 'Your order is on the way to your address';
      case 'Delivered':
        return 'Your order has been Delivered Successfully';
      default:
        return 'Status Unknown';
    }
  }
}

class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCurrent;

  StatusIndicator({
    required this.label,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.shade800
                    : isCurrent
                        ? Colors.green.shade800
                        : Colors.blueGrey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: isActive
                  ? Colors.green
                  : isCurrent
                      ? Colors.green.shade800
                      : Colors.blueGrey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.green.shade800 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

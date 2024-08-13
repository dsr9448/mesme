import 'package:flutter/material.dart';
import 'package:mesme/models/ordermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/services/api_service.dart';
import 'package:mesme/widgets/navbar.dart';
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
    _searchController.addListener(() {
      _filterOrders(_searchController.text);
    });
  }

  void _fetchOrders() {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
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
      // Navigate or show a snackbar if necessary
      // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

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
          cursorColor: Colors.black,
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
                backgroundColor: MaterialStatePropertyAll(Colors.black)),
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
                      return ListTile(
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                            if (order.status == 'Order Placed')
                              GestureDetector(
                                onTap: () {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      text: 'Do you want to cancel your order?',
                                      title: 'Confirm Cancelation',
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
                            );
                          },
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.black)),
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
                          );
                        },
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
              backgroundColor: MaterialStatePropertyAll(Colors.black)),
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
    // final availableItemsTotal = _calculateAvailableItemsTotal(order.categories);

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
                                '₹${order.totalPrice}',
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
                                          '${order.rating}',
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
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      )
                    : CreativeDeliveryStatus(status: order.status),
                Divider(thickness: 1, color: Colors.grey[300]),
                const SizedBox(height: 16),
                if (order.status == 'Accepted' &&
                    order.deliveryPartnerName != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Partner: ${order.deliveryPartnerName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          launch('tel:${order.deliveryPartnerPhone}');
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                      ),
                    ],
                  ),
                // const SizedBox(height: 16),

                ...order.categories.map((category) => OrderDetailsSection(
                      orders: [category],
                    )),
                const SizedBox(height: 16),
                (order.status != 'Cancelled')
                    ? Container(
                        // margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.black,
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
                                    '₹ ${double.parse(order.totalPrice) - _calculateGSTAndServiceCharge(double.parse(order.totalPrice))}',
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
                                    '₹ ${_calculateGSTAndServiceCharge(double.parse(order.totalPrice))}',
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
                                  const Text(
                                    'Amount Payable: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '₹ ${double.parse(order.totalPrice)}',
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
                              order.status == 'Delivered'
                                  ? Container(
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

  double _calculateGSTAndServiceCharge(double totalAmount) {
    if (totalAmount >= 0 && totalAmount <= 200) {
      return 25;
    } else if (totalAmount >= 301 && totalAmount <= 400) {
      return 35;
    } else if (totalAmount >= 401 && totalAmount <= 501) {
      return 45;
    } else {
      // For amounts greater than 400, increase by 25 for every additional 100
      int extraRange = ((totalAmount - 500) / 100).ceil();
      return 45 + (extraRange * 10);
    }
  }
  // double _calculateAvailableItemsTotal(List<OrderCategory> categories) {
  //   double total = 0.0;

  //   for (var category in categories) {
  //     for (var item in category.items) {
  //       if (item.isAvailable) {
  //         total += item.price * item.quantity;
  //       }
  //     }
  //   }

  //   return total;
  // }

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
  OrderDetailsSection({required this.orders});
  @override
  Widget build(BuildContext context) {
    Map<String, List<OrderCategory>> categorizedOrders = {};
    print(' orders ${orders}');
    // Group orders by category
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
                            '₹ ${item.quantity * item.price}',
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
                            item.isAvailable == 1
                                ? "Accepted"
                                : "(Unavailable)",
                            style: TextStyle(
                              fontSize: 14,
                              color: item.isAvailable == 1
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
        return 'Estimated Arrival: 2 hours';
      case 'Accepted':
        return 'Estimated Arrival: 1.5 hours';
      case 'Preparing':
        return 'Estimated Arrival: 2 hours';
      case 'Picked up':
        return 'Estimated Arrival: 1.5 hours';
      case 'On The Way':
        return 'Estimated Arrival: 1 hour';
      case 'Delivered':
        return 'Delivered';
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
                    ? (isCurrent ? Colors.blue : Colors.green)
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: isActive ? Colors.green : Colors.grey,
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
              color: isCurrent ? Colors.blue : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

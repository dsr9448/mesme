import 'package:flutter/material.dart';

class Order {
  final String orderId;
  final String orderDate;
  final double totalPrice;
  final double rating;
  final String status;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalPrice,
    required this.rating,
    required this.status,
  });
}

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final List<Order> orders = [
    Order(
        orderId: '12345',
        orderDate: '2024-07-29',
        totalPrice: 120.5,
        rating: 4.5,
        status: 'In Transit'),
    Order(
        orderId: '98765',
        orderDate: '2024-07-28',
        totalPrice: 89.9,
        rating: 4.0,
        status: 'Delivered'),
    Order(
        orderId: '56789',
        orderDate: '2024-07-27',
        totalPrice: 45.0,
        rating: 3.8,
        status: 'Preparing'),
  ];

  List<Order> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    filteredOrders = orders;
  }

  void _filterOrders(String query) {
    final filtered = orders.where((order) {
      final orderIdLower = order.orderId.toLowerCase();
      final orderDateLower = order.orderDate.toLowerCase();
      final searchLower = query.toLowerCase();

      return orderIdLower.contains(searchLower) ||
          orderDateLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredOrders = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leadingWidth: 0,
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        title: TextField(
          cursorColor: Colors.black,
          decoration: const InputDecoration(
            hintText: 'Search Orders...',
            // prefixStyle: TextStyle(color: Colors.black),
            // hintStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          onChanged: _filterOrders,
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
      body: Column(
        children: [
          const Text(
            'Orders Histroy',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          // const Text('Orders Histroy', style: TextStyle(fontSize: 24)),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return ListTile(
                  title: Text('Order #${order.orderId}'),
                  subtitle: Text(
                      'Date: ${order.orderDate}\nTotal: ₹${order.totalPrice}\nStatus: ${order.status}'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(order: order),
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
}

class OrderDetailPage extends StatelessWidget {
  final Order order;

  OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.green,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Order #${order.orderId}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Date: ${order.orderDate}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Total Price: ₹${order.totalPrice}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Rating: ${order.rating}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.star,
                  color: Colors.yellow[700],
                ),
              ],
            ),
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          OrderDetailsSection(
            sectionTitle: 'Food Items',
            items: [
              OrderDetailsCategory(
                category: 'Burger King',
                items: [
                  'Chicken Alfredo - 1',
                  'Grilled Salmon - 2',
                ],
              ),
              OrderDetailsCategory(
                category: 'Coffee Day',
                items: [
                  'Coke - 2',
                  'Orange Juice - 1',
                ],
              ),
            ],
          ),
          OrderDetailsSection(
            sectionTitle: 'Grocery Items',
            items: [
              OrderDetailsCategory(
                category: 'Fruits & Vegetables',
                items: [
                  'Apples - 5',
                  'Bananas - 6',
                  'Carrots - 2 kg',
                ],
              ),
              OrderDetailsCategory(
                category: 'Dairy & Eggs',
                items: [
                  'Milk - 2 liters',
                  'Cheese - 200 g',
                  'Eggs - 12',
                ],
              ),
              OrderDetailsCategory(
                category: 'Bakery',
                items: [
                  'Bread - 1 loaf',
                  'Croissants - 4',
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Delivery Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          CreativeDeliveryStatus(status: order.status),
        ],
      ),
    );
  }
}

class OrderDetailsSection extends StatelessWidget {
  final String sectionTitle;
  final List<OrderDetailsCategory> items;

  OrderDetailsSection({
    required this.sectionTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          for (var item in items) item,
          SizedBox(height: 16),
          Divider(thickness: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}

class OrderDetailsCategory extends StatelessWidget {
  final String category;
  final List<String> items;

  OrderDetailsCategory({
    required this.category,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          for (var item in items)
            Text(
              item,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
        ],
      ),
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
          Text(
            'Current Status: $status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: getStatusProgress(status),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(getStatusColor(status)),
          ),
          SizedBox(height: 8),
          Text(
            getEstimatedArrival(status),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  double getStatusProgress(String status) {
    switch (status) {
      case 'Preparing':
        return 0.2;
      case 'In Transit':
        return 0.5;
      case 'Delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Preparing':
        return Colors.orange;
      case 'In Transit':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getEstimatedArrival(String status) {
    switch (status) {
      case 'Preparing':
        return 'Estimated Arrival: 2 hours';
      case 'In Transit':
        return 'Estimated Arrival: 1 hour';
      case 'Delivered':
        return 'Delivered';
      default:
        return 'Status Unknown';
    }
  }
}

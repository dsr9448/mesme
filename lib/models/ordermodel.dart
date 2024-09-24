import 'dart:convert';

class Order {
  final String orderId;
  final String orderDate;
  final String totalPrice;
  final String rating;
  final String status;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final Map<String, List<OrderCategory>> categories;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalPrice,
    required this.rating,
    required this.status,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.categories,
  });

  factory Order.fromMap(Map<String, dynamic> json) {
    var itemsMap = json['items'] as Map<String, dynamic>;
    Map<String, List<OrderCategory>> categories = {};

    itemsMap.forEach((categoryName, items) {
      categories[categoryName] = (items as List)
          .map((i) => OrderCategory.fromMap(i, categoryName))
          .toList();
    });

    return Order(
      orderId: json['orderId'] as String,
      orderDate: json['orderDate'] as String,
      totalPrice: json['totalPrice'] as String,
      rating: json['rating'] as String,
      status: json['status'] as String,
      deliveryPartnerName: json['deliveryPartnerName'] as String?,
      deliveryPartnerPhone: json['deliveryPartnerPhone'] as String?,
      deliveryAddress: json['deliveryAddress'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      categories: categories,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> itemsMap = {};

    categories.forEach((categoryName, categoryList) {
      itemsMap[categoryName] =
          categoryList.map((category) => category.toMap()).toList();
    });

    return <String, dynamic>{
      'orderId': orderId,
      'orderDate': orderDate,
      'totalPrice': totalPrice,
      'rating': rating,
      'status': status,
      'deliveryPartnerName': deliveryPartnerName,
      'deliveryPartnerPhone': deliveryPartnerPhone,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'items': itemsMap,
    };
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(orderId: $orderId, orderDate: $orderDate, totalPrice: $totalPrice, rating: $rating, status: $status, deliveryPartnerName: $deliveryPartnerName, deliveryPartnerPhone: $deliveryPartnerPhone, deliveryAddress: $deliveryAddress,paymentMethod: $paymentMethod,paymentStatus: $paymentStatus, categories: $categories)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.orderId == orderId &&
        other.orderDate == orderDate &&
        other.totalPrice == totalPrice &&
        other.rating == rating &&
        other.status == status &&
        other.deliveryPartnerName == deliveryPartnerName &&
        other.deliveryPartnerPhone == deliveryPartnerPhone &&
        other.deliveryAddress == deliveryAddress &&
        other.paymentMethod == paymentMethod &&
        other.paymentStatus == paymentStatus &&
        mapEquals(other.categories, categories);
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        orderDate.hashCode ^
        totalPrice.hashCode ^
        rating.hashCode ^
        status.hashCode ^
        deliveryPartnerName.hashCode ^
        deliveryPartnerPhone.hashCode ^
        deliveryAddress.hashCode ^
        paymentMethod.hashCode ^
        paymentStatus.hashCode ^
        categories.hashCode;
  }
}

bool mapEquals(Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
  if (map1.length != map2.length) return false;
  for (var key in map1.keys) {
    if (map2[key] != map1[key]) return false;
  }
  return true;
}

class OrderCategory {
  final String category;
  final String name;
  final int quantity;
  final double price;
  final int isAvailable;

  OrderCategory({
    required this.category,
    required this.name,
    required this.quantity,
    required this.price,
    required this.isAvailable,
  });

  factory OrderCategory.fromMap(Map<String, dynamic> map, String category) {
    return OrderCategory(
      category: category,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: double.parse(map['price'] as String),
      isAvailable: map['isAvailable'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  String toJson() => json.encode(toMap());

  factory OrderCategory.fromJson(String source) =>
      OrderCategory.fromMap(json.decode(source) as Map<String, dynamic>, '');

  @override
  String toString() =>
      'OrderCategory(category: $category, name: $name, quantity: $quantity, price: $price, isAvailable: $isAvailable)';

  @override
  bool operator ==(covariant OrderCategory other) {
    if (identical(this, other)) return true;

    return other.category == category &&
        other.name == name &&
        other.quantity == quantity &&
        other.price == price &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode =>
      category.hashCode ^
      name.hashCode ^
      quantity.hashCode ^
      price.hashCode ^
      isAvailable.hashCode;
}

import 'dart:convert';
import 'package:flutter/foundation.dart';

class Order {
  final String orderId;
  final String orderDate;
  final String totalPrice;
  final String rating;
  final String status;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final List<OrderCategory>
      categories; // Updated to categories to match your JSON

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalPrice,
    required this.rating,
    required this.status,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    required this.categories,
  });

  Order copyWith({
    String? orderId,
    String? orderDate,
    String? totalPrice,
    String? rating,
    String? status,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    List<OrderCategory>? categories,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      orderDate: orderDate ?? this.orderDate,
      totalPrice: totalPrice ?? this.totalPrice,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'orderDate': orderDate,
      'totalPrice': totalPrice,
      'rating': rating,
      'status': status,
      'deliveryPartnerName': deliveryPartnerName,
      'deliveryPartnerPhone': deliveryPartnerPhone,
      'items': categories
          .map((x) => x.toMap())
          .toList(), // Use 'items' instead of 'categories'
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'] as String,
      orderDate: map['orderDate'] as String,
      totalPrice: map['totalPrice'] as String,
      rating: map['rating'] as String,
      status: map['status'] as String,
      deliveryPartnerName: map['deliveryPartnerName'] as String?,
      deliveryPartnerPhone: map['deliveryPartnerPhone'] as String?,
      categories: List<OrderCategory>.from(
        (map['items'] as List<dynamic>).map(
          (x) => OrderCategory.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(orderId: $orderId, orderDate: $orderDate, totalPrice: $totalPrice, rating: $rating, status: $status, deliveryPartnerName: $deliveryPartnerName, deliveryPartnerPhone: $deliveryPartnerPhone, categories: $categories)';
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
        listEquals(other.categories, categories);
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
        categories.hashCode;
  }
}

class OrderCategory {
  final String category;
   final String name;
  final int quantity;
  final double price;
  final int isAvailable;

  // final List<OrderItem> items;

  OrderCategory({
    required this.category,
     required this.name,
    required this.quantity,
    required this.price,
    required this.isAvailable,
    // required this.items,
  });

  OrderCategory copyWith({
    String? category,
    String? name,
    int? quantity,
    double? price,
    int? isAvailable,
    // List<OrderItem>? items,
  }) {
    return OrderCategory(
      category: category ?? this.category,
       name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category, // Field name should match your JSON field name
      'itemName':name ,
      'qty': quantity,
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  factory OrderCategory.fromMap(Map<String, dynamic> map) {
    return OrderCategory(
      category: map['category'] as String, // Field name should match your JSON field name
     name: map['itemName'] as String, // Corrected to match JSON field
      quantity: map['qty'] as int, // Corrected to match JSON field
      price: double.parse(map['price'] as String), // Convert string to double
      isAvailable: map['isAvailable'] as int, // Provide an empty list if 'items' is null
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderCategory.fromJson(String source) =>
      OrderCategory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OrderCategory(category: $category, itemName: $name, qty: $quantity, price: $price, isAvailable: $isAvailable)';

  @override
  bool operator ==(covariant OrderCategory other) {
    if (identical(this, other)) return true;

    return other.category == category && other.name == name &&
        other.quantity == quantity &&
        other.price == price &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode => category.hashCode ^  name.hashCode ^ quantity.hashCode ^ price.hashCode ^ isAvailable.hashCode;
}


// class OrderItem {
//   final String name;
//   final int quantity;
//   final double price;
//   final bool isAvailable;

//   OrderItem({
//     required this.name,
//     required this.quantity,
//     required this.price,
//     required this.isAvailable,
//   });

//   OrderItem copyWith({
//     String? name,
//     int? quantity,
//     double? price,
//     bool? isAvailable,
//   }) {
//     return OrderItem(
//       name: name ?? this.name,
//       quantity: quantity ?? this.quantity,
//       price: price ?? this.price,
//       isAvailable: isAvailable ?? this.isAvailable,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'itemName': name,
//       'quantity': quantity,
//       'price': price,
//       'isAvailable': isAvailable,
//     };
//   }

//   factory OrderItem.fromMap(Map<String, dynamic> map) {
//     return OrderItem(
//       name: map['itemName'] as String, // Corrected to match JSON field
//       quantity: map['qty'] as int, // Corrected to match JSON field
//       price: double.parse(map['price'] as String), // Convert string to double
//       isAvailable: map['isAvailable'] as bool,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory OrderItem.fromJson(String source) =>
//       OrderItem.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() =>
//       'OrderItem(name: $name, quantity: $quantity, price: $price, isAvailable: $isAvailable)';

//   @override
//   bool operator ==(covariant OrderItem other) {
//     if (identical(this, other)) return true;

//     return other.name == name &&
//         other.quantity == quantity &&
//         other.price == price &&
//         other.isAvailable == isAvailable;
//   }

//   @override
//   int get hashCode =>
//       name.hashCode ^ quantity.hashCode ^ price.hashCode ^ isAvailable.hashCode;
// }

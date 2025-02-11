import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
Widget customSwitch(Color color, bool status, ValueChanged<bool> onToggle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FlutterSwitch(
        width: 104.0,
        height: 38.0,
        valueFontSize: 14.0,
        toggleSize: 25.0,
        value: status,
        borderRadius: 30.0,
        padding: 4.0,
        activeText: color == Colors.green
            ? 'Veg'
            : color == Colors.red[800]
                ? 'Non-Veg'
                : color == Colors.orange
                    ? '4.0★'
                    : 'All',
        inactiveText: color == Colors.green
            ? 'Veg'
            : color == Colors.red[800]
                ? 'Non-Veg'
                : color == Colors.orange
                    ? '4.0★'
                    : 'All',
        activeTextColor: Colors.white,
        inactiveTextColor: Colors.grey.shade700,
        showOnOff: true,
        activeIcon: color == Colors.green
            ? const Icon(Icons.eco_outlined, color: Colors.white, size: 16)
            : color == Colors.red[800]
                ? const Icon(Icons.restaurant_menu,
                    color: Colors.white, size: 16)
                : color == Colors.orange
                    ? const Icon(Icons.star, color: Colors.white, size: 16)
                    : const Icon(Icons.fastfood, color: Colors.white, size: 16),
        inactiveIcon: color == Colors.green
            ? Icon(Icons.eco_outlined, color: Colors.grey.shade400, size: 16)
            : color == Colors.red[800]
                ? Icon(Icons.restaurant_menu,
                    color: Colors.grey.shade400, size: 16)
                : color == Colors.orange
                    ? Icon(Icons.star, color: Colors.grey.shade400, size: 16)
                    : Icon(Icons.fastfood,
                        color: Colors.grey.shade400, size: 16),
        activeColor: color,
        inactiveColor: Colors.white,
        inactiveSwitchBorder: Border.all(color: Colors.grey.shade300, width: 1),
        onToggle: onToggle,
      ),
    );
  }
  Widget customHeading(String title) {
    return Row(
  children: [
    Text(
      '$title',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: Container(
        height: 2,
        color: Colors.orange.shade700,
      ),
    ),
  ],
);
  }
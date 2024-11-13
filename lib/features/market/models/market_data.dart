import 'package:flutter/material.dart';

class MarketData {
  final String symbol;
  final double price;
  final double change;
  final double changePercentage;
  final Color trendColor;

  MarketData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercentage,
  }) : trendColor = change >= 0 ? Colors.green : Colors.red;

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'],
      price: double.parse(json['price'].toString()),
      change: double.parse(json['change'].toString()),
      changePercentage: double.parse(json['changePercentage'].toString()),
    );
  }
}
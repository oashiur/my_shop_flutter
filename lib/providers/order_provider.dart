import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../providers/cart_provider.dart';

class MyOrder {
  final String id;
  final int amount;
  final List<MyCart> products;
  final DateTime dateTime;

  MyOrder({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class OrderProvider with ChangeNotifier {
  final String _userId;

  List<MyOrder> _orders = [];
  final String _authToken;

  OrderProvider(this._authToken, this._userId, this._orders);

  List<MyOrder> get orders => [..._orders];

  Future<void> addOrder(List<MyCart> products, int total) async {
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/orders/$_userId.json?auth=$_authToken');
    final currentTime = DateTime.now();
    final response = await http.post(url,
        body: jsonEncode({
          'amount': total,
          'dateTime': currentTime.toIso8601String(),
          'products': products
              .map((cart) => {
                    'id': cart.id,
                    'productId': cart.productId,
                    'title': cart.title,
                    'imageUrl': cart.imageUrl,
                    'quantity': cart.quantity,
                    'price': cart.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      MyOrder(
        id: jsonDecode(response.body)['name'],
        amount: total,
        products: products,
        dateTime: currentTime,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchData() async {
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/orders/$_userId.json?auth=$_authToken');

    try {
      List<MyOrder> fetchedData = [];
      final response = await http.get(url);
      if (jsonDecode(response.body) != null) {
        final extractData = jsonDecode(response.body) as Map<String, dynamic>;
        extractData.forEach((orderId, orderData) {
          fetchedData.add(
            MyOrder(
              id: orderId,
              amount: orderData['amount'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>).map((cart) {
                return MyCart(
                    id: cart['id'],
                    productId: cart['productId'],
                    title: cart['title'],
                    imageUrl: cart['imageUrl'],
                    quantity: cart['quantity'],
                    price: cart['price']);
              }).toList(),
            ),
          );
        });
      }
      _orders = fetchedData.reversed.toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

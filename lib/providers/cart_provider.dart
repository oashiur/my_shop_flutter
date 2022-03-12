import 'package:flutter/material.dart';

class MyCart {
  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  int quantity;
  final int price;

  MyCart({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    this.quantity = 1,
    required this.price,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, MyCart> _item = {};

  Map<String, MyCart> get item {
    return {..._item};
  }

  void resetCart() {
    _item = {};
    notifyListeners();
  }

  int get totatAmount {
    int total = 0;
    _item.forEach((key, myItem) {
      total += myItem.price * myItem.quantity;
    });
    return total;
  }

  void addItem({
    required String title,
    required String productId,
    required String imageUrl,
    required int price,
  }) {
    if (_item.containsKey(productId)) {
      _item[productId]!.quantity++;
    } else {
      _item.putIfAbsent(
        productId,
        () => MyCart(
          id: DateTime.now().toString(),
          productId: productId,
          title: title,
          imageUrl: imageUrl,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_item.containsKey(productId)) {
      _item.remove(productId);
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_item.containsKey(productId)) {
      return;
    }
    if (_item[productId]!.quantity > 1) {
      _item[productId]!.quantity--;
    } else {
      _item.remove(productId);
    }
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_item.containsKey(productId)) {
      _item[productId]!.quantity++;
    }
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (_item.containsKey(productId)) {
      _item[productId]!.quantity--;
    }
    notifyListeners();
  }

  bool isAddedToCart(String productId) => _item.containsKey(productId);
}

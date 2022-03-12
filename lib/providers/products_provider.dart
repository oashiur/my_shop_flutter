import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class MyProduct with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  bool isFavorite;
  MyProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String authToken, String userId) async {
    bool? oldFav = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/userFavorite/$userId/$id.json?auth=$authToken');

    final response = await http.put(url, body: jsonEncode(isFavorite));

    if (response.statusCode != 200) {
      isFavorite = oldFav;
      notifyListeners();
    } else {
      oldFav = null;
    }
  }
}

class ProductProvider with ChangeNotifier {
  final String _authToken;
  final String _userId;

  ProductProvider(this._authToken, this._userId, this._items, this._myProducts);

  List<MyProduct> _items = [];
  List<MyProduct> _myProducts = [];

  List<MyProduct> get item {
    return [..._items];
  }

  List<MyProduct> get myProducts {
    return [..._myProducts];
  }

  final MyProduct _blankProduct = MyProduct(
    id: DateTime.now().toString(),
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  List<MyProduct> get favoriteList {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchData() async {
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/products.json?auth=$_authToken');

    try {
      List<MyProduct> fetchedData = [];
      final response = await http.get(url);
      if (jsonDecode(response.body) != null) {
        final fURL = Uri.parse(
            '$databaseURL/userFavorite/$_userId.json?auth=$_authToken');
        final fResponse = await http.get(fURL);
        final favoriteData = jsonDecode(fResponse.body);
        final extractData = jsonDecode(response.body) as Map<String, dynamic>;

        extractData.forEach((_, products) {
          products.forEach((productId, productData) {
            fetchedData.add(
              MyProduct(
                id: productId,
                title: productData['title'],
                description: productData['description'],
                price: productData['price'],
                imageUrl: productData['imageUrl'],
                isFavorite: favoriteData == null
                    ? false
                    : favoriteData[productId] ?? false,
              ),
            );
          });
        });
      }
      _items = fetchedData;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMyProduts() async {
    try {
      List<MyProduct> temp = [];
      const databaseURL = 'YOUR DATABASE URL';
      final url = Uri.parse('$databaseURL/products/$_userId.json?auth=$_authToken');
      final response = await http.get(url);
      if (jsonDecode(response.body) != null) {
        final userProducts = jsonDecode(response.body) as Map<String, dynamic>;
        userProducts.forEach((productId, productDate) {
          temp.add(MyProduct(
              id: productId,
              title: productDate['title'],
              description: productDate['description'],
              price: productDate['price'],
              imageUrl: productDate['imageUrl']));
        });
      }
      _myProducts = temp;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(MyProduct product) async {
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/products/$_userId.json?auth=$_authToken');
    try {
      var response = await http.post(url,
          body: jsonEncode(
            {
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
            },
          ));
      final newProduct = MyProduct(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          isFavorite: product.isFavorite);
      _items.add(newProduct);
      _myProducts.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, MyProduct product) async {
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/products/$_userId/$id.json?auth=$_authToken');
    int index = _myProducts.indexWhere((product) => product.id == id);
    if (index != -1) {
      try {
        await http.patch(url,
            body: jsonEncode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
            }));
        _myProducts[index] = product;
        _items[_items.indexWhere((product) => product.id == id)] = product;
      } catch (e) {
        rethrow;
      }
    }
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    const databaseURL = 'YOUR DATABASE URL';
    final url = Uri.parse('$databaseURL/products/$_userId/$id.json?auth=$_authToken');

    int index = _myProducts.indexWhere((product) => product.id == id);
    MyProduct? temp = _myProducts[index];

    _myProducts.removeAt(index);
    _items.removeAt(_items.indexWhere((product) => product.id == id));

    notifyListeners();

    try {
      var response = await http.delete(url);

      if (response.statusCode != 200) {
        _items.insert(index, temp);
        _myProducts.insert(index, temp);
        notifyListeners();
        throw HttpExtention(message: 'Deleting Fail!');
      }
      temp = null;
    } catch (e) {
      rethrow;
    }
  }

  MyProduct findById(String id) {
    return _items.firstWhere(
      (product) => product.id == id,
      orElse: () => _blankProduct,
    );
  }

  bool doesProductExit(String id) {
    int _index = _items.indexWhere((product) => product.id == id);
    if (_index == -1) {
      return false;
    } else {
      return true;
    }
  }
}

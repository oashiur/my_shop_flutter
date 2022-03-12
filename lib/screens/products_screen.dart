import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/my_drawer.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  static const routeName = '/products-screen';

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _showFavorite = false;
  String _dropdownValue = 'All Products';
  late Future _fatchedData;

  @override
  void initState() {
    super.initState();
    _fatchedData =
        Provider.of<ProductProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    AppBar _appBar = AppBar(
      title: const Text('My Shop'),
      actions: [
        Consumer<CartProvider>(
          builder: (_, cart, cld) {
            return Badge(
              child: cld!,
              value: cart.item.length,
              color: Colors.red,
            );
          },
          child: IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(CartScreen.routeName),
            icon: const Icon(Icons.shopping_cart),
          ),
        ),
      ],
    );

    final mediaQuery = MediaQuery.of(context);
    final deviceHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        _appBar.preferredSize.height;

    return Scaffold(
      appBar: _appBar,
      drawer: const MyDrawer(),
      body: FutureBuilder(
        future: _fatchedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(child: Text('Something went wrong!'));
            } else {
              return Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Text('View:', style: TextStyle(fontSize: 17)),
                        const Spacer(),
                        DropdownButton(
                          value: _dropdownValue,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'All Products',
                              child: Text('All Products'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'My Favorites',
                              child: Text('My Favorites'),
                            ),
                          ],
                          onChanged: (String? choosen) {
                            setState(() {
                              _dropdownValue = choosen!;
                              if (choosen == 'My Favorites') {
                                _showFavorite = true;
                              } else {
                                _showFavorite = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight - 50,
                    child: ProductsGridView(_showFavorite),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}

class ProductsGridView extends StatelessWidget {
  final bool favorite;
  const ProductsGridView(this.favorite, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final products = favorite ? productData.favoriteList : productData.item;
    return products.isEmpty
        ? const Center(
            child: Text('No Product Available'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem(key: ValueKey(products[index].id)),
            ),
          );
  }
}

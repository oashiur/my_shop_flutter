import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/add_edit_product_screen.dart';
import '../widgets/my_product_item.dart';
import '../widgets/my_drawer.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({Key? key}) : super(key: key);

  static const routeName = '/my-products-screen';

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late Future _fatchedData;

  @override
  void initState() {
    super.initState();
    _fatchedData =
        Provider.of<ProductProvider>(context, listen: false).fetchMyProduts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(AddEditProductScreen.routeName),
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder(
          future: _fatchedData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Consumer<ProductProvider>(
                builder: (context, productData, _) {
                  return productData.myProducts.isEmpty
                      ? const Center(child: Text('You don\'t have any product.'))
                      : ListView.builder(
                          itemCount: productData.myProducts.length,
                          itemBuilder: (context, index) {
                            return MyProductItem(
                              id: productData.myProducts[index].id,
                              title: productData.myProducts[index].title,
                              imageUrl: productData.myProducts[index].imageUrl,
                            );
                          },
                        );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/add_edit_product_screen.dart';

class MyProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  const MyProductItem(
      {required this.id, required this.title, required this.imageUrl, Key? key})
      : super(key: key);

  // void snackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final productData = Provider.of<ProductProvider>(context, listen: false);
    return ListTile(
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context)
                .pushNamed(AddEditProductScreen.routeName, arguments: id),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
              onPressed: () async {
                try {
                  await productData.removeProduct(id);
                } catch (exception) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(exception.toString()),
                      duration: const Duration(milliseconds: 1500),
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ))
        ],
      ),
    );
  }
}

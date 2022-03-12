import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/products_provider.dart' show MyProduct;
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<MyProduct>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Stack(
      children: [
        GridTile(
          child: GestureDetector(
            onTap: (() => Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: product)),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: Consumer<MyProduct>(
              builder: (_, value, __) => IconButton(
                onPressed: () => product.toggleFavoriteStatus(auth.token, auth.userId),
                icon: value.isFavorite
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    : const Icon(Icons.favorite_border),
              ),
            ),
            title: Text(product.title, textAlign: TextAlign.center),
            trailing: Consumer<CartProvider>(builder: (_, cart, __) {
              return IconButton(
                onPressed: () {
                  cart.addItem(
                    productId: product.id,
                    title: product.title,
                    imageUrl: product.imageUrl,
                    price: product.price,
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to Cart'),
                      duration: const Duration(milliseconds: 1500),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => cart.removeSingleItem(product.id),
                      ),
                    ),
                  );
                },
                icon: cart.isAddedToCart(product.id)
                    ? const Icon(
                        Icons.shopping_cart,
                        color: Colors.blue,
                      )
                    : const Icon(Icons.shopping_cart),
              );
            }),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          color: Colors.red,
          child: Text(
            '\u09F3${product.price}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

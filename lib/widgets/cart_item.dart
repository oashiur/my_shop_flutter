import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final MyCart cartItem;
  const CartItem(this.cartItem, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Row(
      children: [
        Column(
          children: [
            IconButton(
              onPressed: () => cart.increaseQuantity(cartItem.productId),
              icon: const Icon(Icons.keyboard_arrow_up),
            ),
            Text(
              cartItem.quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: cartItem.quantity < 2 ? null : () => cart.decreaseQuantity(cartItem.productId),
              disabledColor: Colors.grey,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 60,
            width: 60,
            child: Image.network(
              cartItem.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Text(
              cartItem.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              '\u09F3${cartItem.price} X ${cartItem.quantity}',
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
        const Spacer(),
        Text(
          '\u09F3${cartItem.price * cartItem.quantity}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}

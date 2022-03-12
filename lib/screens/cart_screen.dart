import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/cart_item.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  static const String routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final order = Provider.of<OrderProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cart.item.isEmpty
          ? const Center(
              child: Text('Your Cart is Empty'),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ...cart.item.values.toList().map(
                    (cartItem) {
                      return Dismissible(
                        key: ValueKey(cartItem.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            size: 34,
                            color: Colors.white,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: CartItem(cartItem),
                        onDismissed: (_) {
                          cart.removeItem(cartItem.productId);
                        },
                        confirmDismiss: (_) {
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content: const Text(
                                      'Do you want to remove this from cart?'),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('No')),
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Yes')),
                                  ],
                                );
                              });
                        },
                      );
                    },
                  ).toList(),
                  const Divider(
                    thickness: 1.5,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '\u09F3${cart.totatAmount}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MyButton(order: order, cart: cart),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class MyButton extends StatefulWidget {
  const MyButton({
    Key? key,
    required this.order,
    required this.cart,
  }) : super(key: key);

  final OrderProvider order;
  final CartProvider cart;

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? (){} : () async {
        setState(() {
          _isLoading = true;
        });
        await widget.order.addOrder(
            widget.cart.item.values.toList(), widget.cart.totatAmount);
        setState(() {
          _isLoading = false;
        });
        widget.cart.resetCart();
      },
      child: SizedBox(
        height: 40,
        width: 200,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                )
              : const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}

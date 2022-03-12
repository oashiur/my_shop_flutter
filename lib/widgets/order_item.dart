import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/order_provider.dart';

class OrderItem extends StatefulWidget {
  final MyOrder myOrder;
  const OrderItem(this.myOrder, {Key? key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('\u09F3${widget.myOrder.amount}'),
          subtitle:
              Text(DateFormat('dd/MM/yyyy').add_jm().format(widget.myOrder.dateTime)),
          trailing: IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: widget.myOrder.products.map((cart){
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cart.title),
                    Text('${cart.quantity} X \u09F3${cart.price}')
                  ],
                );
              }).toList(),
                  
            ),
          )
      ],
    );
  }
}

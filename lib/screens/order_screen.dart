import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/my_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  static const String routeName = '/order-screen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future _fetchedData;

  @override
  void initState() {
    super.initState();
    _fetchedData =
        Provider.of<OrderProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder(
        future: _fetchedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(child: Text('Something went wrong!'));
            } else {
              return Consumer<OrderProvider>(
                builder: (context, orders, __) {
                  return orders.orders.isEmpty
                      ? SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have any order!',
                                style: TextStyle(fontSize: 20),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('/'),
                                child: const Text('Shop Now'),
                              )
                            ],
                          ),
                        )
                      : Column(
                          children: orders.orders.map(
                            (myOrder) {
                              return OrderItem(myOrder);
                            },
                          ).toList(),
                        );
                },
              );
            }
          }
        },
      ),
    );
  }
}

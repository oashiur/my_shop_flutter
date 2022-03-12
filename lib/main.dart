import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/products_provider.dart';
import './providers/order_provider.dart';
import './providers/cart_provider.dart';

import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_screen.dart';
import './screens/add_edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/my_products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (context) => ProductProvider('', '', [], []),
          update: (context, auth, previous) => ProductProvider(
              auth.token,
              auth.userId,
              previous == null ? [] : previous.item,
              previous == null ? [] : previous.myProducts),
        ),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (context) => OrderProvider('', '', []),
          update: (context, auth, previous) => OrderProvider(
              auth.token, auth.userId, previous == null ? [] : previous.orders),
        ),
      ],
      child: Consumer<AuthProvider>(builder: (ctx, auth, child) {
        return MaterialApp(
          title: 'My Shop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? const ProductsScreen()
              : FutureBuilder(
                  future: auth.isLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const AuthScreen();
                    }
                  }),
          routes: {
            AuthScreen.routeName: (context) => const AuthScreen(),
            ProductsScreen.routeName: (context) => const ProductsScreen(),
            ProductDetailScreen.routeName: (context) => const ProductDetailScreen(),
            CartScreen.routeName: (context) => const CartScreen(),
            OrderScreen.routeName: (context) => const OrderScreen(),
            MyProductsScreen.routeName: (context) => const MyProductsScreen(),
            AddEditProductScreen.routeName: (context) => const AddEditProductScreen(),
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/my_products_screen.dart';
import '../screens/order_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  Widget drawerItem(
      {required String title,
      required IconData icon,
      required void Function() onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.blue,
              child: const Center(
                  child: Text(
                'Hurry up!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )),
            ),
            drawerItem(
              title: 'Shop',
              icon: Icons.shopping_bag_outlined,
              onTap: () => Navigator.of(context).pushReplacementNamed('/'),
            ),
            drawerItem(
              title: 'My Orders',
              icon: Icons.payment,
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(OrderScreen.routeName),
            ),
            drawerItem(
              title: 'My Products',
              icon: Icons.shopping_basket_outlined,
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(MyProductsScreen.routeName),
            ),
            drawerItem(
              title: 'LogOut',
              icon: Icons.logout,
              onTap: (){
                Navigator.pop(context);
                auth.logOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

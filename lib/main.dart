import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './helpers/custom-route.dart';
import './providers/products.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';
import '../providers/auth.dart';
import './screens/products_overview_screen.dart';
import './screens/splash_screen.dart';
import './screens/user_products_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider< Auth, Products>(
           create: (_) => Products(null,null,[]),
          update: (context, auth , previousProducts) => Products(auth.token, auth.userId,previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(
        create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth,Orders>(
          create: (_) => Orders(null,null,[]),
          update: (context, value, previous) => Orders(value.token,value.userId, previous == null? [] : previous.orders),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx,auth,_) => MaterialApp(
          debugShowCheckedModeBanner: false,
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android : CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                }
              )
            ),
            home: auth.isAuth
            ?ProductsOverviewScreen() 
            :FutureBuilder(
              future: auth.autoLogin(),
              builder: (context, snapshot) 
                => snapshot.connectionState == ConnectionState.waiting 
                ?SplashScreen()
                :AuthScreen()
            ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName:(ctx) => CartScreen(),
              OrdersScreen.routeName:(ctx) => OrdersScreen(),
              UserProductScreen.routeName:(ctx) => UserProductScreen(),
              EditProductScreen.routeName:(ctx) => EditProductScreen()
            }),
      )
    );
  }
}

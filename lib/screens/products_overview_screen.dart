// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import './cart_screen.dart';
import '../providers/cart.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/products.dart';
enum FilterOptions{
  Favorites,
  All
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var isInit = true;
  var isLoading = false;

  @override
  void didChangeDependencies() {
    if(isInit){
      setState(() {
        isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_){
        setState(() {
          isLoading = false;
        });
      } );
    }
    isInit = false;
    super.didChangeDependencies();
  }
  // void initState() {
  //   Future.delayed(Duration.zero).then((_) {
  //     Provider.of<Products>(context).fetchAndSetProducts();
  //   });
  //   super.initState();
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions value) {
              setState(() {
                if (value == FilterOptions.Favorites){
                _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              }); 
            },
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('Only Favorites'),value: FilterOptions.Favorites,),
              PopupMenuItem(child: Text('Show All'),value: FilterOptions.All,),

            ]
          ),
          Consumer<Cart>(
            builder: (_ , cart , ch) => Badge(
              value: cart.itemCount.toString(),
              color: Colors.deepOrange,
              child: ch ?? const Icon(Icons.shopping_cart)
            ),
            child: IconButton(
                icon: Icon(
                  Icons.shopping_cart
                ), onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading? Center(child: CircularProgressIndicator(),) : ProductsGrid(_showOnlyFavorites),
    );
  }
}

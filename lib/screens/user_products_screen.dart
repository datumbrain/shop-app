import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/product.dart';

import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName= '/user-products';
  Future<void> _refreshProducts(BuildContext context) async{
    await Provider.of<Products>(context,listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
  //final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: 'newProduct');
            }, 
            icon: const Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting ?
        const Center(
          child: CircularProgressIndicator(),
        )
        : RefreshIndicator(
          onRefresh: () => _refreshProducts(context), 
          child: Consumer<Products>(
            builder: (ctx, productsData, _) => Padding(
              padding:const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: productsData.items.length,
                itemBuilder: (_, index) => 
                Column(
                  children: [
                    UserProductItem(
                      productsData.items[index].id,
                      productsData.items[index].title, 
                      productsData.items[index].imageUrl),
                    const Divider()
                  ],
                )
              ),
            ),
          ),
        ),
      )
    );
  }
}
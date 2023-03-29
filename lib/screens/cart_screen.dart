import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  //const CartScreen({super.key});
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                 const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20
                    )
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) =>
                CartItem(
                  cart.items.values.toList()[index].id, 
                  cart.items.keys.toList()[index],
                  cart.items.values.toList()[index].title , 
                  cart.items.values.toList()[index].price,
                  cart.items.values.toList()[index].quantity, 
                )
            )
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return isLoading ? CircularProgressIndicator() :
    TextButton(
      onPressed: widget.cart.totalAmount <= 0 ? null : () async{
        setState(() {
          isLoading = true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.items.values.toList(), 
          widget.cart.totalAmount
        );
        setState(() {
          isLoading = false;
        });
        widget.cart.clearcart();
      },
      child: const Text(
        'ORDER NOW',
      ),
    );
  }
}
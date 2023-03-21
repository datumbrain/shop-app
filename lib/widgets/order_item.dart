import 'dart:math';

import 'package:flutter/material.dart';
import '../providers/orders.dart';
import 'package:intl/intl.dart';

class OrderWidget extends StatefulWidget {
  final OrderItem order;

  const OrderWidget(this.order);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              onPressed: (() {
                setState(() {
                  _expanded = !_expanded;
                });
              }) ,
              icon: _expanded ? 
              const Icon(Icons.expand_less)
              : const Icon(Icons.expand_more),
            ),
          ),
          if(_expanded) Container( 
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 4),
            height: min(widget.order.products.length *20 +10, 180),
            child: ListView(
              children: widget.order.products
              .map(
                (prod) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prod.title,style: 
                      const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                      ),
                    ),
                    Text('${prod.quantity} x \$${prod.price}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey
                      ),
                    )
                  ],
                )
              ).toList()
            ),
          )
        ],
      ),
    );
  }
}
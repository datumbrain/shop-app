import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price
  });
}



class Cart with ChangeNotifier {
  Map<String, CartItem>? _items = { };

  Map<String, CartItem> get items {
    return {...?_items};
  }

  int get itemCount{
    return _items?.length ?? 0;
  }

  double get totalAmount{
    var total = 0.0;
     _items?.forEach((key, cartItem) {
     total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items!.containsKey(productId)){
      _items?.update(
        productId, 
        (existing) => CartItem(id: existing.id, title: existing.title, quantity: existing.quantity+1, price: existing.price));
    } else {
      _items?.putIfAbsent(
        productId, 
        () => CartItem(
          id: DateTime.now().toString(), 
          title: title,  
          price: price, 
          quantity: 1,
        )
      );
    }
    notifyListeners();
  }

  void removeItem(String id){
    _items?.remove(id);
    notifyListeners();
  }

  void clearcart (){
    _items = {};
    notifyListeners();
  }
}
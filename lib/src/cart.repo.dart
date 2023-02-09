import 'dart:async';
import 'package:product/product.dart';

import 'cart.state.dart';


class CartRepo {

  final controller = StreamController<CartState>.broadcast();
  Stream<CartState> get items => controller.stream.asBroadcastStream();
  List<ProductEnum> list = [];

  // todo! determine currency symbol from product
  addToCart(ProductEnum product) {
    final newList = list.toList();
    newList.add(product);
    list = newList;
    final listItems = list.map((e) => e.toListItemsForCart(
        '£${list.totalPrice().toStringAsFixed(2)}'
    ))
        .toList();
    controller.sink.add(CartState.some(list,listItems));
  }

  reset(){
    controller.sink.add(const CartState.some([],[]));
  }

  double getPrice(){
    return list.fold(0.0, (a, b) => a+b.priceDouble());
  }

  double getPricePlusPercent(double d){
    final price =  list.fold(0.0, (a, b) => a+b.priceDouble());
    return price+(price*d);
  }

}


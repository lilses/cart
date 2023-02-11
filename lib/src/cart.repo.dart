import 'dart:async';
import 'package:address/address.dart';
import 'package:list_component/list_component.dart';
import 'package:product/product.dart';

import 'cart.state.dart';


class CartRepo {

  final controller = StreamController<CartState>.broadcast();
  Stream<CartState> get items => controller.stream.asBroadcastStream();
  List<ProductEnum> list = [];

  // todo! determine currency symbol from product
  addToCart(List<ProductEnum> products, List<ListItem> listItems, QAddress? address) {
    controller.sink.add(CartState.some(products,listItems,address));
  }



}


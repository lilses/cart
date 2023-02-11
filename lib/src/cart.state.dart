import 'package:address/address.dart';
import 'package:list_component/list_component.dart';
import 'package:product/product.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.state.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState.some(
      List<ProductEnum> products,
      List<ListItem> listItems,
      QAddress? deliveryAddress
      ) = _Some;
}

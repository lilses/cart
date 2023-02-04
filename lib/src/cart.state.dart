import 'package:product/product.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.state.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState.some(List<ProductEnum> products) = _Some;
}

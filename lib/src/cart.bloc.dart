import 'dart:async';

import 'package:product/product.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart.repo.dart';
import 'cart.state.dart';

class CartBloc extends Cubit<CartState> {
  final CartRepo cartRepo;

  late final StreamSubscription cartRepoSubscription;

  CartBloc({
    required this.cartRepo
  }) : super(const CartState.some([])){
    subscribe();
  }

  @override
  Future<void> close() {
    cartRepoSubscription.cancel();
    return super.close();
  }

  void subscribe() {
    cartRepoSubscription = cartRepo.items.listen(
          (items){
        emit(CartState.some(items.products));
      },
      onError: (error) => print("STREAM ERROR: $error"),
    );
  }

  List<ProductEnum> get cart => state.products;


  double getPrice(){
    return state.products.fold(0.0, (a, b) => a+b.priceDouble());
  }

  double getPricePlusPercent(double d){
    final price =  state.products.fold(0.0, (a, b) => a+b.priceDouble());
    return price+(price*d);
  }
}

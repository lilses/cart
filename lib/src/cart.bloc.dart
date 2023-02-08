import 'dart:async';

import 'package:list_component/list_component.dart';
import 'package:product/product.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart.repo.dart';
import 'cart.state.dart';

class CartBloc extends Cubit<CartState> {
  final CartRepo cartRepo;

  late final StreamSubscription cartRepoSubscription;

  CartBloc({
    required this.cartRepo
  }) : super(const CartState.some([],[])){
    subscribe();
  }


  @override
  Future<void> close() {
    cartRepoSubscription.cancel();
    return super.close();
  }

  void subscribe() {
    cartRepoSubscription = cartRepo.items.listen(
          (event){
            final total = [
              ...state.products.toList(),
              ...event.products
            ];
            print("total len ${event.products.length} ${event.products.totalPrice()}");
        final listItems = event
            .products
            .map((e) => e.toListItemsForCart(
                '£${event.products.totalPrice().toStringAsFixed(2)}'
              ))
            .toList();
        emit(CartState.some(event.products,listItems));
      },
      onError: (error) => print("STREAM ERROR: $error"),
    );
  }

  void retrigger(){
    final a = state.products;
    final b = state.listItems;
    emit(const CartState.some([],[]));
    emit(CartState.some(a,b));
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

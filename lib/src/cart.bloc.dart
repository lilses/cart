import 'dart:async';

import 'package:list_component/list_component.dart';
import 'package:product/product.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe/stripe.dart';
import 'package:transferwise/transferwise.dart';

import 'cart.repo.dart';
import 'cart.state.dart';

class CartBloc extends Cubit<CartState> {
  final CartRepo cartRepo;

  late final StreamSubscription cartRepoSubscription;
  final StripeRepo stripeRepo;
  final TransferwiseRepo transferwiseRepo;

  CartBloc({
    required this.cartRepo,
    required this.stripeRepo,
    required this.transferwiseRepo,
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
        emit(CartState.some(event.products,event.listItems));
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


  addToCart(ProductEnum product) {
    final productList = state.products.toList();
    productList.add(product);
    final listItems = productList.map((e) => e.toListItemsForCart(
        '£${productList.totalPrice().toStringAsFixed(2)}'
    ))
    .toList();
    final stripeListItem = stripeRepo.toListItem();
    final transferwiseListItem = transferwiseRepo.toListItem();
    listItems.add(stripeListItem);
    listItems.add(transferwiseListItem);
    cartRepo.addToCart(productList, listItems);
  }

  // List<ListItem> paymentListItems(){
  //   final List<ListItem> list = [];
  //   final stripeListItem = stripeRepo.toListItem();
  //   final transferwiseListItem = transferwiseRepo.toListItem();
  //   list.add(stripeListItem);
  //   list.add(transferwiseListItem);
  //   return list;
  // }
}

import 'dart:async';

import 'package:address/address.dart';
import 'package:list_component/list_component.dart';
import 'package:nav/nav.dart';
import 'package:product/product.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe/stripe.dart';
import 'package:transferwise/transferwise.dart';
import 'package:router/router.dart';
import 'cart.repo.dart';
import 'cart.state.dart';

class CartBloc extends Cubit<CartState> {
  final CartRepo cartRepo;
  final StripeRepo stripeRepo;
  final AddressRepo addressRepo;

  final TransferwiseRepo transferwiseRepo;
  final RouterRepo routerRepo;
  RouterState? _routerState;

  late final StreamSubscription cartRepoSubscription;
  late final StreamSubscription routerRepoSubscription;
  late final StreamSubscription addressRepoSubscription;


  CartBloc({
    required this.addressRepo,
    required this.cartRepo,
    required this.stripeRepo,
    required this.transferwiseRepo,
    required this.routerRepo,
  }) : super(const CartState.some([], [], null)) {
    subscribe();
  }

  @override
  Future<void> close() {
    cartRepoSubscription.cancel();
    return super.close();
  }

  void subscribe() {
    addressRepoSubscription = addressRepo.items.listen(
          (event) {
        emit(CartState.some(state.products, state.listItems, event.deliveryAddress));
      },
      onError: (error) => print("STREAM ERROR: $error"),
    );
    cartRepoSubscription = cartRepo.items.listen(
      (event) {
        emit(CartState.some(event.products, event.listItems, state.deliveryAddress));
      },
      onError: (error) => print("STREAM ERROR: $error"),
    );
    routerRepoSubscription = routerRepo.items.listen(
      (event) {
        _routerState = event;
      },
      onError: (error) => print("STREAM ERROR: $error"),
    );
  }

  void retrigger() {
    final a = state.products;
    final b = state.listItems;
    final c = state.deliveryAddress;
    emit(const CartState.some([], [], null));
    emit(CartState.some(a, b, c));
  }

  List<ProductEnum> get cart => state.products;

  addToCart(ProductEnum product) {
    final productList = state.products.toList();
    productList.add(product);
    final listItems = productList
        .map((e) => e.toListItemsForCart(
            '£${productList.totalPrice().toStringAsFixed(2)}'))
        .toList();
    final stripeListItem = stripeRepo.toListItem();
    final transferwiseListItem = transferwiseRepo.toListItem();
    listItems.add(stripeListItem);
    listItems.add(transferwiseListItem);
    cartRepo.addToCart(productList, listItems, state.deliveryAddress);
  }

  navigateToStripe() {
    // final n = state.deliveryAddress == null ? NavEnum.
    if (_routerState != null) {
      _routerState!.mapOrNull(
          some: (some) => routerRepo.changeRoute(RouterState.some(
              some.uri.replace(
                path: NavEnum.stripe.path.replaceAll("/", ""),
              ),
              NavEnum.stripe)));
    }
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

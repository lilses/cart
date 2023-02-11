import 'dart:async';

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
  final AddressRepo stripeRepo;

  final TransferwiseRepo transferwiseRepo;
  final RouterRepo routerRepo;
  RouterState? _routerState;

  late final StreamSubscription cartRepoSubscription;
  late final StreamSubscription routerRepoSubscription;

  CartBloc({
    required this.cartRepo,
    required this.stripeRepo,
    required this.transferwiseRepo,
    required this.routerRepo,
  }) : super(const CartState.some([], [])) {
    subscribe();
  }

  @override
  Future<void> close() {
    cartRepoSubscription.cancel();
    return super.close();
  }

  void subscribe() {
    cartRepoSubscription = cartRepo.items.listen(
      (event) {
        emit(CartState.some(event.products, event.listItems));
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
    emit(const CartState.some([], []));
    emit(CartState.some(a, b));
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
    cartRepo.addToCart(productList, listItems);
  }

  navigateToStripe() {
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

import 'dart:async';
import 'package:list_component/list_component.dart';

class CartListItemRepo {

  final controller = StreamController<ListItemState>.broadcast();
  Stream<ListItemState> get items => controller.stream.asBroadcastStream();

  Future<void> append(List<ListItem> listItem) async {
    controller.sink.add(ListItemState.some(listItem, false));
  }

}


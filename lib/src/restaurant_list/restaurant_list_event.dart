import 'dart:async';
import 'dart:developer' as developer;

import '../repository/model/restaurant.dart';
import 'index.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

@immutable
abstract class RestaurantListEvent {
  Future<RestaurantListState> applyAsync(
      {RestaurantListState? currentState, RestaurantListBloc? bloc});
}

class UnRestaurantListEvent extends RestaurantListEvent {
  @override
  Future<RestaurantListState> applyAsync(
      {RestaurantListState? currentState, RestaurantListBloc? bloc}) async {
    return UnRestaurantListState(0);
  }
}

class LoadRestaurantListEvent extends RestaurantListEvent {
  final List<Restaurant> restaurants;
  @override
  String toString() => 'LoadRestaurantListEvent';

  LoadRestaurantListEvent(this.restaurants);

  Future<List<Tuple2<Restaurant, List<String>>>> fetchRestaurantWithPhotos(
      RestaurantListBloc? bloc) async {
    List<Tuple2<Restaurant, List<String>>> list = [];
    await Future.forEach(restaurants, (dynamic r) async {
      Tuple2<Restaurant, List<String>> item =
          Tuple2(r, await bloc!.getRestaurantPhotos(r));
      list.add(item);
    });
    return list;
  }

  @override
  Future<RestaurantListState> applyAsync(
      {RestaurantListState? currentState, RestaurantListBloc? bloc}) async {
    try {
      if (currentState is InRestaurantListState) {
        return currentState.getNewVersion();
      }

      // if (restaurants != null) {
      //   Future<List<Tuple2<Restaurant, List<String>>>>
      //       futureRestaurantWithPhotos;

      //   List<Tuple2<Restaurant, List<String>>> list = [];

      //   Future.forEach(restaurants, (r) async {
      //     Tuple2<Restaurant, List<String>> item =
      //         Tuple2(r, await bloc.getRestaurantPhotos(r));
      //     list.add(item);
      //   });

      //   fetchRestaurantWithPhotos(bloc);

      //   restaurantWithPhotos = restaurants.map((element) async {
      //     return Tuple2(element, await bloc.getRestaurantPhotos(element));
      //   }).toList();
      // }
      return InRestaurantListState(0, fetchRestaurantWithPhotos(bloc));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadRestaurantListEvent', error: _, stackTrace: stackTrace);
      return ErrorRestaurantListState(0, _.toString());
    }
  }
}

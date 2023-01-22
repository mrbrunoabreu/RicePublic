import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rice/src/find_restaurant/find_restaurant_bloc.dart';
import 'package:rice/src/find_restaurant/find_restaurant_state.dart';
import 'package:rice/src/utils.dart';
import 'dart:developer' as developer;

@immutable
abstract class FindRestaurantEvent {
  Future<FindRestaurantState> applyAsync({
    FindRestaurantState? currentState,
    FindRestaurantBloc? bloc,
  });
}

class UnFindRestaurantEvent extends FindRestaurantEvent {
  @override
  Future<FindRestaurantState> applyAsync({
    FindRestaurantState? currentState,
    FindRestaurantBloc? bloc,
  }) async {
    return InFindRestaurantState(0, restaurants: []);
  }
}

class SearchByNameEvent extends FindRestaurantEvent {
  final String name;

  SearchByNameEvent({
    required this.name,
  });

  @override
  Future<FindRestaurantState> applyAsync({
    FindRestaurantState? currentState,
    FindRestaurantBloc? bloc,
  }) async {
    Position userLocation = await loadUserLastLocation();

    final restaurants = await bloc!.findRestaurantsByName(
      name: this.name,
      location: userLocation,
    );

    developer.log('State should be updating with ${restaurants.length}');

    return InFindRestaurantState(
      currentState is InFindRestaurantState ? currentState.version + 1 : 1,
      restaurants: restaurants,
    );
  }
}

class LoadFindRestaurantEvent extends FindRestaurantEvent {
  @override
  Future<FindRestaurantState> applyAsync({
    FindRestaurantState? currentState,
    FindRestaurantBloc? bloc,
  }) async {
    // final restaurants = await bloc.findRestaurantsByName(name: '');

    return InFindRestaurantState(
      1,
      restaurants: [],
    );
  }
}

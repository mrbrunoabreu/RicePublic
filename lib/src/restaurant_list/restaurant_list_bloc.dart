import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/model/restaurant.dart';
import '../repository/rice_repository.dart';
import 'index.dart';

import '../base_bloc.dart';

class RestaurantListBloc
    extends BaseBloc<RestaurantListEvent, RestaurantListState> {
  RestaurantListBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnRestaurantListState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<String>> getRestaurantPhotos(Restaurant restaurant) {
    return riceRepository.restaurantPhotos(restaurant);
  }

  @override
  Future<void> mapEventToState(
    RestaurantListEvent event,
    Emitter<RestaurantListState> emitter,
  ) async {
    try {
      emitter(UnRestaurantListState(0));
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'RestaurantListBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

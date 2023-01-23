import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../base_bloc.dart';
import 'find_restaurant_event.dart';
import 'find_restaurant_state.dart';
import '../repository/model/restaurant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:developer' as developer;

import '../repository/model/user.dart';
import '../repository/rice_repository.dart';
import 'package:rxdart/rxdart.dart';

class FindRestaurantBloc
    extends BaseBloc<FindRestaurantEvent, FindRestaurantState> {
  FindRestaurantBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: InFindRestaurantState(
              0,
              restaurants: [],
            )) {
    on<FindRestaurantEvent>(mapEventToState, transformer: debounce());
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  @override
  FindRestaurantState get initialState => InFindRestaurantState(
        0,
        restaurants: [],
      );

  Future<List<Restaurant>> findRestaurantsByName({
    required String name,
    required Position location,
  }) {
    return this.riceRepository.restaurantsWithKeyword(
          name,
          location.latitude,
          location.longitude,
        );
  }

  Future<User> getUser() {
    return this.riceRepository.getCurrentUser();
  }

  EventTransformer<FindRestaurantEvent> debounce<FindRestaurantEvent>(
      {Duration duration = const Duration(milliseconds: 500)}) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  @override
  Future<void> mapEventToState(
    FindRestaurantEvent event,
    Emitter<FindRestaurantState> emitter,
  ) async {
    try {
      emitter(UnFindRestaurantState(1));
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'FindRestaurantBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

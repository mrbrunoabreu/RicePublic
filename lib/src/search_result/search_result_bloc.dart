import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';
import 'index.dart';
import 'package:tuple/tuple.dart';

import '../base_bloc.dart';

class SearchResultBloc extends BaseBloc<SearchResultEvent, SearchResultState> {
  SearchResultBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnSearchResultState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<User>> findUserByName(String name) {
    return riceRepository.findUserByName(name);
  }

  Future<List<Restaurant>> findRestaurantsByKeyword(
    String keyword,
    double lat,
    double lng,
  ) {
    return riceRepository.restaurantsWithKeyword(keyword, lat, lng);
  }

  Future<Tuple2<Restaurant, List<String>>> findRestaurantPhotos(
    Restaurant restaurant,
  ) {
    return riceRepository
        .restaurantPhotos(restaurant)
        .then((value) => Tuple2(restaurant, value));
  }

  @override
  Future<void> mapEventToState(
    SearchResultEvent event,
    Emitter<SearchResultState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'SearchResultBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

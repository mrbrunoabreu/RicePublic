import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/review.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/restaurant_detail/index.dart';

import '../base_bloc.dart';

class RestaurantDetailBloc
    extends BaseBloc<RestaurantDetailEvent, RestaurantDetailState> {
  RestaurantDetailBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnRestaurantDetailState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<String>> getRestaurantPhotos(Restaurant? restaurant) {
    return riceRepository.restaurantPhotos(restaurant);
  }

  Future<bool?> checkIsInWantToGoList(Restaurant? restaurant) {
    return riceRepository.checkIsInWantToGoList(restaurant);
  }

  Future<bool?> checkIsInBeenList(Restaurant? restaurant) {
    return riceRepository.checkIsInBeenList(restaurant);
  }

  Future<bool> checkIsInMyLists(Restaurant? restaurant) {
    return riceRepository.checkIsInMyLists(restaurant);
  }

  Future<bool> checkIsInFavoriteList(Restaurant? restaurant) {
    return riceRepository.checkIsInFavouriteList(restaurant);
  }

  Future<bool> toggleWantToGoList(Restaurant? restaurant) {
    return riceRepository.toggleRestaurantWantToGoList(restaurant);
  }

  Future<bool> toggleToBeenList(Restaurant? restaurant) {
    return riceRepository.toggleRestaurantToBeenList(restaurant);
  }

  Future<bool> toggleToMyLists(
    Restaurant restaurant,
    String listId,
    bool isAdd,
  ) {
    return riceRepository.addRestaurantToMyLists(restaurant, listId, isAdd);
  }

  Future<bool> addToFavouriteList(Restaurant? restaurant, bool isAdd) {
    return riceRepository.addRestaurantToFavouriteList(restaurant, isAdd);
  }

  Future<List<Review>> getReviews(String? restaurantId) {
    return riceRepository.restaurantReviews(restaurantId);
  }

  Future<ReviewRatings> getRestaurantRatings(Restaurant? restaurant) async {
    //return await riceRepository.restaurantOverallRating(restaurant);
    return ReviewRatings();
  }

  Future<User> getCurrentUser() async {
    await isLoggedIn();
    return await riceRepository.getCurrentUser();
  }

  @override
  Future<void> mapEventToState(
    RestaurantDetailEvent event,
    Emitter<RestaurantDetailState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'RestaurantDetailBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

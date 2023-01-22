import 'dart:async';
import 'dart:developer' as developer;

import '../repository/model/restaurant.dart';
import '../repository/model/review.dart';
import '../repository/model/user.dart';
import 'package:rice/src/restaurant_detail/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RestaurantDetailEvent {
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc});
  // final RestaurantDetailRepository _restaurantDetailRepository = RestaurantDetailRepository();
}

class UnRestaurantDetailEvent extends RestaurantDetailEvent {
  @override
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc}) async {
    return UnRestaurantDetailState(0);
  }
}

class LoadRestaurantDetailEvent extends RestaurantDetailEvent {
  final Restaurant? restaurant;
  @override
  String toString() => 'LoadRestaurantDetailEvent';

  LoadRestaurantDetailEvent(this.restaurant);

  Future<bool> _haveReviewed(List<Review> reviews, User currentUser) async {
    bool haveReviewed = false;
    await Future.forEach(reviews, (Review r) {
      haveReviewed |= (r.userId == currentUser.id);
      return Future.value(haveReviewed);
    });
    return haveReviewed;
  }

  @override
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc}) async {
    try {
      if (currentState is InRestaurantDetailState) {
        return currentState.getNewVersion();
      }

      List<Review> reviews = await bloc!.getReviews(restaurant!.id);
      List<String> photos = await bloc.getRestaurantPhotos(restaurant);

      ReviewRatings ratings = await bloc.getRestaurantRatings(restaurant);
      bool hasReviewed = false;
      // ignore: todo
      // TODO: keep, in case needed
      // bool hasReviewed = await bloc
      //     .getCurrentUser()
      //     .then((user) => _haveReviewed(reviews, user));

      bool? isAddToWantToGoList = await bloc.checkIsInWantToGoList(restaurant);
      bool? isAddToBeenList = await bloc.checkIsInBeenList(restaurant);
      bool isAddToMyLists = await bloc.checkIsInMyLists(restaurant);
      bool isAddToFavouritesList = await bloc.checkIsInFavoriteList(restaurant);

      final currentUser = await bloc.getCurrentUser();

      // this._restaurantDetailRepository.test(this.isError);
      return InRestaurantDetailState(
        0,
        photos,
        reviews,
        ratings,
        hasReviewed,
        isAddToWantToGoList,
        isAddToBeenList,
        isAddToMyLists,
        isAddToFavouritesList,
        currentUser,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadRestaurantDetailEvent', error: _, stackTrace: stackTrace);
      return ErrorRestaurantDetailState(0, _.toString());
    }
  }
}

class OnAddToWantToGoListEvent extends RestaurantDetailEvent {
  final Restaurant? restaurant;

  OnAddToWantToGoListEvent(this.restaurant);

  @override
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc}) async {
    bool isAdd = await bloc!
        .toggleWantToGoList(restaurant)
        .catchError((error, stackTrace) {
      developer.log('$error',
          name: 'OnAddToWantToGoListEvent',
          error: error,
          stackTrace: stackTrace);
      return ErrorRestaurantDetailState(0, error.toString());
    });

    return (currentState as InRestaurantDetailState)
        .getNewVersionWith(isAddToWantToGoList: isAdd);
  }

  @override
  String toString() => 'OnAddToListEvent';
}

class OnAddToBeenListEvent extends RestaurantDetailEvent {
  final Restaurant? restaurant;

  OnAddToBeenListEvent(this.restaurant);

  @override
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc}) async {
    bool isAdd = await bloc!
        .toggleToBeenList(restaurant)
        .catchError((error, stackTrace) {
      developer.log('$error',
          name: 'OnAddToWantToGoListEvent',
          error: error,
          stackTrace: stackTrace);
      return ErrorRestaurantDetailState(0, error.toString());
    });

    return (currentState as InRestaurantDetailState)
        .getNewVersionWith(isAddToBeenList: isAdd);
  }

  @override
  String toString() => 'OnAddToBeenListEvent';
}

class OnAddToMyListsEvent extends RestaurantDetailEvent {
  final Restaurant restaurant;
  final String listId;

  OnAddToMyListsEvent(this.restaurant, this.listId);

  @override
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc}) async {
    bool isAdd = await bloc!
        .toggleToMyLists(restaurant, listId,
            (currentState as InRestaurantDetailState).isAddToMyLists)
        .catchError((error, stackTrace) {
      developer.log('$error',
          name: 'OnAddToWantToGoListEvent',
          error: error,
          stackTrace: stackTrace);
      return ErrorRestaurantDetailState(0, error.toString());
    });

    return currentState.getNewVersionWith(isAddToMyLists: isAdd);
  }

  @override
  String toString() => 'OnAddToListEvent';
}

class OnAddToFavoriteListEvent extends RestaurantDetailEvent {
  final Restaurant? restaurant;

  OnAddToFavoriteListEvent(this.restaurant);

  @override
  Future<RestaurantDetailState> applyAsync(
      {RestaurantDetailState? currentState, RestaurantDetailBloc? bloc}) async {
    bool isAdd = await bloc!
        .addToFavouriteList(restaurant,
            (currentState as InRestaurantDetailState).isAddToFavoritesList)
        .catchError((error, stackTrace) {
      developer.log('$error',
          name: 'OnAddToWantToGoListEvent',
          error: error,
          stackTrace: stackTrace);
      return ErrorRestaurantDetailState(0, error.toString());
    });

    return currentState.getNewVersionWith(isAddToFavouritesList: isAdd);
  }

  @override
  String toString() => 'OnAddToFavouriteListEvent';
}

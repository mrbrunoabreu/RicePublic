import 'dart:async';
import 'dart:developer' as developer;

import 'package:image_picker/image_picker.dart';

import '../repository/model/restaurant.dart';
import '../repository/model/review.dart';
import 'index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RestaurantReviewEvent {
  Future<RestaurantReviewState> applyAsync(
      {RestaurantReviewState? currentState, RestaurantReviewBloc? bloc});
}

class UnRestaurantReviewEvent extends RestaurantReviewEvent {
  @override
  Future<RestaurantReviewState> applyAsync(
      {RestaurantReviewState? currentState, RestaurantReviewBloc? bloc}) async {
    return UnRestaurantReviewState(0);
  }
}

class ErrorRestaurantReviewEvent extends RestaurantReviewEvent {
  final Exception e;
  ErrorRestaurantReviewEvent(this.e);

  @override
  Future<RestaurantReviewState> applyAsync(
      {RestaurantReviewState? currentState, RestaurantReviewBloc? bloc}) async {
    return ErrorRestaurantReviewState(0, e.toString());
  }
}

class LoadRestaurantReviewEvent extends RestaurantReviewEvent {
  final Restaurant restaurant;
  @override
  String toString() => 'LoadRestaurantReviewEvent';

  LoadRestaurantReviewEvent(this.restaurant);

  @override
  Future<RestaurantReviewState> applyAsync(
      {RestaurantReviewState? currentState, RestaurantReviewBloc? bloc}) async {
    try {
      if (currentState is! UnRestaurantReviewState) {
        return currentState!.getNewVersion();
      }
      return InRestaurantReviewState(0, '');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadRestaurantReviewEvent', error: _, stackTrace: stackTrace);
      return ErrorRestaurantReviewState(0, _.toString());
    }
  }
}

class PostRestaurantReviewEvent extends RestaurantReviewEvent {
  final Restaurant restaurant;
  final Review review;
  final List<XFile> photos;

  @override
  String toString() => 'PostRestaurantReviewEvent';

  PostRestaurantReviewEvent(this.restaurant, this.review, this.photos);

  @override
  Future<RestaurantReviewState> applyAsync(
      {RestaurantReviewState? currentState, RestaurantReviewBloc? bloc}) async {
    try {
      await bloc!.postReview(restaurant, review, photos);
      return PostedRestaurantReviewState(0);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'PostRestaurantReviewEvent', error: _, stackTrace: stackTrace);
      return ErrorRestaurantReviewState(0, _.toString());
    }
  }
}

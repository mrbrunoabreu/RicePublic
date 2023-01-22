import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:rice/src/explore/index.dart';
import 'package:meta/meta.dart';
import 'package:rice/src/repository/rice_meteor_service.dart' show FollowingsRestaurantReviewsSubscription;

import '../utils.dart';

@immutable
abstract class ExploreEvent {
  Future<Position> loadUserLocation() async {
    return loadUserLastLocation();
  }

  Future<ExploreState> applyAsync(
      {ExploreState? currentState, ExploreBloc? bloc});
}

class UnExploreEvent extends ExploreEvent {
  @override
  Future<ExploreState> applyAsync(
      {ExploreState? currentState, ExploreBloc? bloc}) async {
    return UnExploreState(0);
  }
}

class ClickedSearchExploreEvent extends ExploreEvent {
  @override
  Future<ExploreState> applyAsync(
      {ExploreState? currentState, ExploreBloc? bloc}) async {
    return ShowSearchPanelState(0);
  }
}

class LoadExploreEvent extends ExploreEvent {
  final bool _loadMore;
  final bool _refresh;

  @override
  String toString() => 'LoadExploreEvent';

  LoadExploreEvent({bool loadMore = false, bool refresh = false})
    : _loadMore = loadMore, _refresh = refresh;

  @override
  Future<ExploreState> applyAsync(
      {ExploreState? currentState, ExploreBloc? bloc}) async {
    try {
      if (currentState is InExploreState) {
        if (_loadMore && !_refresh) {
          currentState.subscription.nextPage();
          return currentState;
        } else {
          currentState.subscription.unsubscribe();
        }
      }

      Position position = await loadUserLocation();
      // var restaurants =
      //     await bloc.fetchRecommendation(position.latitude, position.longitude);

      // var latestPosts = await bloc.fetchLatestPosts();

      var plans = await bloc!.fetchPublicPlans(
        position.latitude,
        position.longitude,
      );

      FollowingsRestaurantReviewsSubscription subscription = 
        bloc.subscribeFollowingsReviews();

      return InExploreState(
        _refresh? currentState!.version: 0,
        [],
        plans,
        [],
        position.latitude,
        position.longitude,
        subscription,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadExploreEvent', error: _, stackTrace: stackTrace);
      return ErrorExploreState(0, _.toString());
    }
  }
}

import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/plan.dart';
import '../repository/model/editorial.dart';
import '../repository/model/restaurant.dart';
import '../repository/rice_meteor_service.dart'
    show FollowingsRestaurantReviewsSubscription;
import 'package:tuple/tuple.dart';

abstract class ExploreState extends Equatable with LoaderController {
  static const String restaurants = 'restaurants';
  static const String error = 'error';
  static const String plans = 'plans';

  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ExploreState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ExploreState getStateCopy();

  ExploreState getNewVersion();

  @override
  List get props => propss!;
}

/// UnInitialized
class UnExploreState extends ExploreState with NeedShowLoader {
  UnExploreState(int version) : super(version);

  @override
  String toString() => 'UnExploreState';

  @override
  UnExploreState getStateCopy() {
    return UnExploreState(0);
  }

  @override
  UnExploreState getNewVersion() {
    return UnExploreState(version + 1);
  }
}

class ShowSearchPanelState extends ExploreState {
  ShowSearchPanelState(int version) : super(version);

  @override
  ExploreState getNewVersion() {
    return ShowSearchPanelState(version + 1);
  }

  @override
  ExploreState getStateCopy() {
    return ShowSearchPanelState(this.version);
  }
}

/// Initialized
class InExploreState extends ExploreState {
  final List<CarouselBanner> latestPosts;
  final List<Restaurant> restaurants;
  final List<Plan> plans;
  final double currentLat;
  final double currentLng;
  final FollowingsRestaurantReviewsSubscription subscription;

  InExploreState(
    int version,
    this.restaurants,
    this.plans,
    this.latestPosts,
    this.currentLat,
    this.currentLng,
    this.subscription,
  ) : super(version, [
          Tuple4<String, Object, String, Object>(
              ExploreState.restaurants, restaurants, ExploreState.plans, plans)
        ]);

  @override
  String toString() => 'InExploreState $restaurants';

  @override
  InExploreState getStateCopy() {
    return InExploreState(this.version, this.restaurants, this.plans,
        this.latestPosts, this.currentLat, this.currentLat, this.subscription);
  }

  @override
  InExploreState getNewVersion() {
    return InExploreState(version + 1, this.restaurants, this.plans,
        this.latestPosts, this.currentLat, this.currentLat, this.subscription);
  }
}

class ErrorExploreState extends ExploreState {
  final String errorMessage;

  ErrorExploreState(int version, this.errorMessage)
      : super(version, [
          Tuple4<String, Object, String?, Object?>(
              ExploreState.error, errorMessage, null, null)
        ]);

  @override
  String toString() => 'ErrorExploreState';

  @override
  ErrorExploreState getStateCopy() {
    return ErrorExploreState(this.version, this.errorMessage);
  }

  @override
  ErrorExploreState getNewVersion() {
    return ErrorExploreState(version + 1, this.errorMessage);
  }
}

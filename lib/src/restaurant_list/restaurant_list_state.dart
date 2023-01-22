import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/restaurant.dart';
import 'package:tuple/tuple.dart';

abstract class RestaurantListState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  RestaurantListState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  RestaurantListState getStateCopy();

  RestaurantListState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnRestaurantListState extends RestaurantListState with NeedShowLoader {
  UnRestaurantListState(int version) : super(version);

  @override
  String toString() => 'UnRestaurantListState';

  @override
  UnRestaurantListState getStateCopy() {
    return UnRestaurantListState(0);
  }

  @override
  UnRestaurantListState getNewVersion() {
    return UnRestaurantListState(version + 1);
  }
}

/// Initialized
class InRestaurantListState extends RestaurantListState {
  final Future<List<Tuple2<Restaurant, List<String>>>> restaurantWithPhotos;

  InRestaurantListState(int version, this.restaurantWithPhotos)
      : super(version, [restaurantWithPhotos]);

  @override
  String toString() => 'InRestaurantListState $restaurantWithPhotos';

  @override
  InRestaurantListState getStateCopy() {
    return InRestaurantListState(this.version, this.restaurantWithPhotos);
  }

  @override
  InRestaurantListState getNewVersion() {
    return InRestaurantListState(version + 1, this.restaurantWithPhotos);
  }
}

class ErrorRestaurantListState extends RestaurantListState {
  final String errorMessage;

  ErrorRestaurantListState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorRestaurantListState';

  @override
  ErrorRestaurantListState getStateCopy() {
    return ErrorRestaurantListState(this.version, this.errorMessage);
  }

  @override
  ErrorRestaurantListState getNewVersion() {
    return ErrorRestaurantListState(version + 1, this.errorMessage);
  }
}

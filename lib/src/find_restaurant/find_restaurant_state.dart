import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import '../repository/model/restaurant.dart';

abstract class FindRestaurantState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  FindRestaurantState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  FindRestaurantState getStateCopy();

  FindRestaurantState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

class InFindRestaurantState extends FindRestaurantState {
  final List<Restaurant> restaurants;

  InFindRestaurantState(int version, {required this.restaurants})
      : super(version, [version, restaurants]);

  @override
  String toString() => 'InFindRestaurantState $version';

  @override
  InFindRestaurantState getStateCopy() {
    return InFindRestaurantState(
      this.version,
      restaurants: this.restaurants,
    );
  }

  @override
  InFindRestaurantState getNewVersion() {
    return InFindRestaurantState(
      version + 1,
      restaurants: this.restaurants,
    );
  }
}

class UnFindRestaurantState extends InFindRestaurantState with NeedShowLoader {
  UnFindRestaurantState(int version) : super(version, restaurants: []);

  @override
  String toString() => 'UnFindRestaurantState $version';

  @override
  UnFindRestaurantState getStateCopy() {
    return UnFindRestaurantState(
      this.version,
    );
  }

  @override
  UnFindRestaurantState getNewVersion() {
    return UnFindRestaurantState(
      version + 1,
    );
  }
}

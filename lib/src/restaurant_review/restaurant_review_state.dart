import 'package:equatable/equatable.dart';
import '../base_bloc.dart';

abstract class RestaurantReviewState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  RestaurantReviewState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  RestaurantReviewState getStateCopy();

  RestaurantReviewState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnRestaurantReviewState extends RestaurantReviewState
    with NeedShowLoader {
  UnRestaurantReviewState(int version) : super(version);

  @override
  String toString() => 'UnRestaurantReviewState';

  @override
  UnRestaurantReviewState getStateCopy() {
    return UnRestaurantReviewState(0);
  }

  @override
  UnRestaurantReviewState getNewVersion() {
    return UnRestaurantReviewState(version + 1);
  }
}

/// Initialized
class InRestaurantReviewState extends RestaurantReviewState {
  final String hello;

  InRestaurantReviewState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InRestaurantReviewState $hello';

  @override
  InRestaurantReviewState getStateCopy() {
    return InRestaurantReviewState(this.version, this.hello);
  }

  @override
  InRestaurantReviewState getNewVersion() {
    return InRestaurantReviewState(version + 1, this.hello);
  }
}

class PostedRestaurantReviewState extends RestaurantReviewState {
  PostedRestaurantReviewState(int version) : super(version, []);

  @override
  String toString() => 'PostedRestaurantReviewState';

  @override
  PostedRestaurantReviewState getStateCopy() {
    return PostedRestaurantReviewState(this.version);
  }

  @override
  PostedRestaurantReviewState getNewVersion() {
    return PostedRestaurantReviewState(version + 1);
  }
}

class ErrorRestaurantReviewState extends RestaurantReviewState {
  final String errorMessage;

  ErrorRestaurantReviewState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorRestaurantReviewState';

  @override
  ErrorRestaurantReviewState getStateCopy() {
    return ErrorRestaurantReviewState(this.version, this.errorMessage);
  }

  @override
  ErrorRestaurantReviewState getNewVersion() {
    return ErrorRestaurantReviewState(version + 1, this.errorMessage);
  }
}

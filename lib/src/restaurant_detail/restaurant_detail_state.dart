import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/review.dart';
import '../repository/model/user.dart';

abstract class RestaurantDetailState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  RestaurantDetailState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  RestaurantDetailState getStateCopy();

  RestaurantDetailState getNewVersion();

  RestaurantDetailState getNewVersionWith();

  @override
  List<Object?> get props => propss!;
}

/// UnInitialized
class UnRestaurantDetailState extends RestaurantDetailState
    with NeedShowLoader {
  UnRestaurantDetailState(int version) : super(version);

  @override
  String toString() => 'UnRestaurantDetailState';

  @override
  UnRestaurantDetailState getStateCopy() {
    return UnRestaurantDetailState(0);
  }

  @override
  UnRestaurantDetailState getNewVersion() {
    return UnRestaurantDetailState(version + 1);
  }

  @override
  RestaurantDetailState getNewVersionWith() {
    throw UnRestaurantDetailState(version + 1);
  }
}

/// Initialized
class InRestaurantDetailState extends RestaurantDetailState {
  final List<String> photos;
  final List<Review> reviews;
  final ReviewRatings ratings;
  final bool hasReviewed;
  final bool? isAddToWantToGoList;
  final bool? isAddToBeenList;
  final bool isAddToMyLists;
  final bool isAddToFavoritesList;
  final User currentUser;

  InRestaurantDetailState(
    int version,
    this.photos,
    this.reviews,
    this.ratings,
    this.hasReviewed,
    this.isAddToWantToGoList,
    this.isAddToBeenList,
    this.isAddToMyLists,
    this.isAddToFavoritesList,
    this.currentUser,
  ) : super(version, [
          photos,
          reviews,
          ratings,
          hasReviewed,
          isAddToWantToGoList,
          isAddToBeenList,
          isAddToMyLists,
          isAddToFavoritesList
        ]);

  @override
  String toString() => 'InRestaurantDetailState Review size ${reviews.length}';

  @override
  InRestaurantDetailState getStateCopy() {
    return InRestaurantDetailState(
      this.version,
      this.photos,
      this.reviews,
      this.ratings,
      this.hasReviewed,
      this.isAddToWantToGoList,
      this.isAddToBeenList,
      this.isAddToMyLists,
      this.isAddToFavoritesList,
      this.currentUser,
    );
  }

  @override
  InRestaurantDetailState getNewVersion() {
    return InRestaurantDetailState(
      version + 1,
      this.photos,
      this.reviews,
      this.ratings,
      this.hasReviewed,
      this.isAddToWantToGoList,
      this.isAddToBeenList,
      this.isAddToMyLists,
      this.isAddToFavoritesList,
      this.currentUser,
    );
  }

  @override
  RestaurantDetailState getNewVersionWith({
    List<String>? photos,
    List<Review>? reviews,
    ReviewRatings? ratings,
    bool? hasReviewed,
    bool? isAddToWantToGoList,
    bool? isAddToBeenList,
    bool? isAddToMyLists,
    bool? isAddToFavouritesList,
    User? currentUser,
  }) {
    return InRestaurantDetailState(
      version + 1,
      photos ?? this.photos,
      reviews ?? this.reviews,
      ratings ?? this.ratings,
      hasReviewed ?? this.hasReviewed,
      isAddToWantToGoList ?? this.isAddToWantToGoList,
      isAddToBeenList ?? this.isAddToBeenList,
      isAddToMyLists ?? this.isAddToMyLists,
      isAddToFavouritesList ?? this.isAddToFavoritesList,
      currentUser ?? this.currentUser,
    );
  }
}

class ErrorRestaurantDetailState extends RestaurantDetailState {
  final String errorMessage;

  ErrorRestaurantDetailState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorRestaurantDetailState';

  @override
  ErrorRestaurantDetailState getStateCopy() {
    return ErrorRestaurantDetailState(this.version, this.errorMessage);
  }

  @override
  ErrorRestaurantDetailState getNewVersion() {
    return ErrorRestaurantDetailState(version + 1, this.errorMessage);
  }

  @override
  RestaurantDetailState getNewVersionWith({String? errorMessage}) {
    return ErrorRestaurantDetailState(
        version + 1, errorMessage ?? this.errorMessage);
  }
}

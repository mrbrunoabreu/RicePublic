import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import 'package:tuple/tuple.dart';

abstract class SearchResultState extends Equatable with LoaderController {
  static const String restaurants = 'restaurants';
  static const String people = 'people';
  static const String error = 'error';

  /// notify change state without deep clone state
  final int version;

  final List<Tuple2<String, Object>>? propss;
  SearchResultState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  SearchResultState getStateCopy();

  SearchResultState getNewVersion();

  @override
  List<Tuple2<String, Object>> get props => propss!;
}

/// UnInitialized
class UnSearchResultState extends SearchResultState with NeedShowLoader {
  UnSearchResultState(int version) : super(version);

  @override
  String toString() => 'UnSearchResultState';

  @override
  UnSearchResultState getStateCopy() {
    return UnSearchResultState(0);
  }

  @override
  UnSearchResultState getNewVersion() {
    return UnSearchResultState(version + 1);
  }
}

/// Initialized
class InSearchResultState extends SearchResultState {
  final List<Tuple2<Restaurant, List<String>>> restaurants;

  InSearchResultState(int version, this.restaurants)
      : super(version, [
          Tuple2<String, Object>(SearchResultState.restaurants, restaurants)
        ]);

  @override
  String toString() => 'InSearchResultState ${restaurants.length}';

  @override
  InSearchResultState getStateCopy() {
    return InSearchResultState(this.version, this.restaurants);
  }

  @override
  InSearchResultState getNewVersion() {
    return InSearchResultState(version + 1, this.restaurants);
  }
}

class InPeopleSearchResultState extends SearchResultState {
  final List<User> people;

  InPeopleSearchResultState(int version, this.people)
      : super(version,
            [Tuple2<String, Object>(SearchResultState.people, people)]);

  @override
  String toString() => 'InPeopleSearchResultState ${people.length}';

  @override
  InPeopleSearchResultState getStateCopy() {
    return InPeopleSearchResultState(this.version, this.people);
  }

  @override
  InPeopleSearchResultState getNewVersion() {
    return InPeopleSearchResultState(version + 1, this.people);
  }
}

class ErrorSearchResultState extends SearchResultState {
  final String errorMessage;

  ErrorSearchResultState(int version, this.errorMessage)
      : super(version,
            [Tuple2<String, Object>(SearchResultState.error, errorMessage)]);

  @override
  String toString() => 'ErrorSearchResultState';

  @override
  ErrorSearchResultState getStateCopy() {
    return ErrorSearchResultState(this.version, this.errorMessage);
  }

  @override
  ErrorSearchResultState getNewVersion() {
    return ErrorSearchResultState(version + 1, this.errorMessage);
  }
}

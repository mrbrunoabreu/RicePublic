import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rice/src/base_bloc.dart';
import 'package:rice/src/repository/model/profile.dart';

abstract class PersonalListsState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  PersonalListsState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  PersonalListsState getStateCopy();

  PersonalListsState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnPersonalListsState extends PersonalListsState with NeedShowLoader {
  UnPersonalListsState(int version) : super(version);

  @override
  String toString() => 'UnPersonalListsState';

  @override
  UnPersonalListsState getStateCopy() {
    return UnPersonalListsState(0);
  }

  @override
  UnPersonalListsState getNewVersion() {
    return UnPersonalListsState(version + 1);
  }
}

class InPersonalListsState extends PersonalListsState {
  final List<ListMetadata> personalLists;

  InPersonalListsState(int version, {required this.personalLists})
      : super(version);

  @override
  String toString() => 'InPersonalListsState';

  @override
  InPersonalListsState getStateCopy() {
    return InPersonalListsState(0, personalLists: this.personalLists);
  }

  @override
  InPersonalListsState getNewVersion() {
    return InPersonalListsState(version + 1, personalLists: this.personalLists);
  }
}

class AddedRestaurantToListState extends InPersonalListsState {
  final List<ListMetadata> personalLists;

  AddedRestaurantToListState(int version, {required this.personalLists})
      : super(
          version,
          personalLists: personalLists,
        );

  @override
  String toString() => 'AddedRestaurantToListState';

  @override
  AddedRestaurantToListState getStateCopy() {
    return AddedRestaurantToListState(0, personalLists: this.personalLists);
  }

  @override
  AddedRestaurantToListState getNewVersion() {
    return AddedRestaurantToListState(version + 1,
        personalLists: this.personalLists);
  }
}

class ErrorPersonalListsState extends PersonalListsState {
  final String errorMessage;

  ErrorPersonalListsState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorPersonalListsState';

  @override
  ErrorPersonalListsState getStateCopy() {
    return ErrorPersonalListsState(this.version, this.errorMessage);
  }

  @override
  ErrorPersonalListsState getNewVersion() {
    return ErrorPersonalListsState(version + 1, this.errorMessage);
  }
}

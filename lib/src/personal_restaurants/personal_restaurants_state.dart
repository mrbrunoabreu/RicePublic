import 'package:equatable/equatable.dart';
import 'package:rice/src/base_bloc.dart';
import 'package:rice/src/repository/model/personal_list.dart';

abstract class PersonalRestaurantsState extends Equatable
    with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  PersonalRestaurantsState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  PersonalRestaurantsState getStateCopy();

  PersonalRestaurantsState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

class UnPersonalRestaurantsState extends PersonalRestaurantsState with NeedShowLoader {
  UnPersonalRestaurantsState(int version) : super(version);

  @override
  String toString() => 'UnPersonalRestaurantsState';

  @override
  UnPersonalRestaurantsState getStateCopy() {
    return UnPersonalRestaurantsState(0);
  }

  @override
  UnPersonalRestaurantsState getNewVersion() {
    return UnPersonalRestaurantsState(version + 1);
  }
}

class InPersonalRestaurantsState extends PersonalRestaurantsState {
  final PersonalList? personalList;

  InPersonalRestaurantsState(
    int version, {
    this.personalList,
  }) : super(version, [personalList]);

  @override
  String toString() => 'InPersonalRestaurantsState';

  @override
  InPersonalRestaurantsState getStateCopy() {
    return InPersonalRestaurantsState(0);
  }

  @override
  InPersonalRestaurantsState getNewVersion() {
    return InPersonalRestaurantsState(version + 1);
  }
}

class ErrorPersonalRestaurantsState extends PersonalRestaurantsState {
  final String errorMessage;

  ErrorPersonalRestaurantsState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorPersonalRestaurantsState';

  @override
  ErrorPersonalRestaurantsState getStateCopy() {
    return ErrorPersonalRestaurantsState(this.version, this.errorMessage);
  }

  @override
  ErrorPersonalRestaurantsState getNewVersion() {
    return ErrorPersonalRestaurantsState(version + 1, this.errorMessage);
  }
}

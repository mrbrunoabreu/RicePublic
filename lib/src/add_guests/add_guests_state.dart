import 'package:equatable/equatable.dart';
import 'package:rice/src/base_bloc.dart';
import '../repository/model/user.dart';

abstract class AddGuestsState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  AddGuestsState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  AddGuestsState getStateCopy();

  AddGuestsState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnAddGuestsState extends AddGuestsState with NeedShowLoader {
  UnAddGuestsState(int version) : super(version);

  @override
  String toString() => 'UnCreatePlanState';

  @override
  UnAddGuestsState getStateCopy() {
    return UnAddGuestsState(0);
  }

  @override
  UnAddGuestsState getNewVersion() {
    return UnAddGuestsState(version + 1);
  }
}

/// Initialized
class InAddGuestsState extends AddGuestsState {
  final List<User> friends;

  InAddGuestsState(int version, this.friends) : super(version, [friends]);

  @override
  String toString() => 'InCreatePlanState';

  @override
  InAddGuestsState getStateCopy() {
    return InAddGuestsState(this.version, this.friends);
  }

  @override
  InAddGuestsState getNewVersion() {
    return InAddGuestsState(version + 1, this.friends);
  }
}

class ErrorAddGuestsState extends AddGuestsState {
  final String errorMessage;

  ErrorAddGuestsState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorCreatePlanState';

  @override
  ErrorAddGuestsState getStateCopy() {
    return ErrorAddGuestsState(this.version, this.errorMessage);
  }

  @override
  ErrorAddGuestsState getNewVersion() {
    return ErrorAddGuestsState(version + 1, this.errorMessage);
  }
}

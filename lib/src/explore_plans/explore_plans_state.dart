import 'package:equatable/equatable.dart';
import 'package:rice/src/base_bloc.dart';
import 'package:rice/src/repository/model/plan.dart';
import 'package:rice/src/repository/model/editorial.dart';
import 'package:rice/src/repository/model/restaurant.dart';
import 'package:tuple/tuple.dart';

abstract class ExplorePlansState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ExplorePlansState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ExplorePlansState getStateCopy();

  ExplorePlansState getNewVersion();

  @override
  List get props => propss!;
}

/// UnInitialized
class UnExplorePlansState extends ExplorePlansState with NeedShowLoader {
  UnExplorePlansState(int version) : super(version);

  @override
  String toString() => 'UnExplorePlansState';

  @override
  UnExplorePlansState getStateCopy() {
    return UnExplorePlansState(0);
  }

  @override
  UnExplorePlansState getNewVersion() {
    return UnExplorePlansState(version + 1);
  }
}

class InExplorePlansState extends ExplorePlansState {
  final List<Plan>? plans;

  InExplorePlansState(
    int version, {
    this.plans,
  }) : super(version, [plans]);

  @override
  String toString() => 'InExplorePlansState $plans';

  @override
  InExplorePlansState getStateCopy() {
    return InExplorePlansState(
      this.version,
      plans: this.plans,
    );
  }

  @override
  InExplorePlansState getNewVersion() {
    return InExplorePlansState(
      version + 1,
      plans: this.plans,
    );
  }
}

class ErrorExplorePlansState extends ExplorePlansState {
  final String errorMessage;

  ErrorExplorePlansState(int version, this.errorMessage)
      : super(version, [
          errorMessage,
        ]);

  @override
  String toString() => 'ErrorExplorePlansState';

  @override
  ErrorExplorePlansState getStateCopy() {
    return ErrorExplorePlansState(this.version, this.errorMessage);
  }

  @override
  ErrorExplorePlansState getNewVersion() {
    return ErrorExplorePlansState(version + 1, this.errorMessage);
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import '../repository/model/plan.dart';

abstract class PlanListState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  PlanListState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  PlanListState getStateCopy();

  PlanListState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnPlanListState extends PlanListState with NeedShowLoader {
  UnPlanListState(int version) : super(version);

  @override
  String toString() => 'UnPlanListState';

  @override
  UnPlanListState getStateCopy() {
    return UnPlanListState(0);
  }

  @override
  UnPlanListState getNewVersion() {
    return UnPlanListState(version + 1);
  }
}

/// Initialized
class InPlanListState extends PlanListState {
  final List<Plan> friendsPlans;
  final List<Plan> myPlans;
  final List<Plan> allPlans;

  InPlanListState(
    int version, {
    required this.friendsPlans,
    required this.myPlans,
    required this.allPlans,
  }) : super(version, [friendsPlans, myPlans]);

  @override
  String toString() => 'InPlanListState $friendsPlans';

  @override
  InPlanListState getStateCopy() {
    return InPlanListState(
      this.version,
      friendsPlans: this.friendsPlans,
      myPlans: this.myPlans,
      allPlans: this.allPlans,
    );
  }

  @override
  InPlanListState getNewVersion() {
    return InPlanListState(
      version + 1,
      friendsPlans: this.friendsPlans,
      myPlans: this.myPlans,
      allPlans: this.allPlans,
    );
  }
}

class ErrorPlanListState extends PlanListState {
  final String errorMessage;

  ErrorPlanListState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorPlanListState';

  @override
  ErrorPlanListState getStateCopy() {
    return ErrorPlanListState(this.version, this.errorMessage);
  }

  @override
  ErrorPlanListState getNewVersion() {
    return ErrorPlanListState(version + 1, this.errorMessage);
  }
}

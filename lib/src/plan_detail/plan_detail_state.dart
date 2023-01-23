import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import '../repository/model/plan.dart';
import '../repository/model/user.dart';

abstract class PlanDetailState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  PlanDetailState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  PlanDetailState getStateCopy();

  PlanDetailState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

/// UnInitialized
class UnPlanDetailState extends PlanDetailState with NeedShowLoader {
  UnPlanDetailState(int version) : super(version);

  @override
  String toString() => 'UnPlanDetailState';

  @override
  UnPlanDetailState getStateCopy() {
    return UnPlanDetailState(0);
  }

  @override
  UnPlanDetailState getNewVersion() {
    return UnPlanDetailState(version + 1);
  }
}

class PlanDeletedState extends PlanDetailState {
  PlanDeletedState(int version) : super(version);

  @override
  String toString() => 'PlanDeletedState';

  @override
  PlanDeletedState getStateCopy() {
    return PlanDeletedState(0);
  }

  @override
  PlanDeletedState getNewVersion() {
    return PlanDeletedState(version + 1);
  }
}

/// Initialized
class InPlanDetailState extends PlanDetailState {
  final User currentUser;
  final Plan? plan;

  InPlanDetailState(
    int version,
    this.plan, {
    required this.currentUser,
  }) : super(version, [plan]);

  @override
  String toString() => 'InPlanDetailState $plan';

  @override
  InPlanDetailState getStateCopy() {
    return InPlanDetailState(
      this.version,
      this.plan,
      currentUser: this.currentUser,
    );
  }

  @override
  InPlanDetailState getNewVersion() {
    return InPlanDetailState(
      version + 1,
      this.plan,
      currentUser: this.currentUser,
    );
  }
}

class ErrorPlanDetailState extends PlanDetailState {
  final String errorMessage;

  ErrorPlanDetailState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorPlanDetailState';

  @override
  ErrorPlanDetailState getStateCopy() {
    return ErrorPlanDetailState(this.version, this.errorMessage);
  }

  @override
  ErrorPlanDetailState getNewVersion() {
    return ErrorPlanDetailState(version + 1, this.errorMessage);
  }
}

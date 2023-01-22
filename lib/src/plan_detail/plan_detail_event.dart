import 'dart:async';
import 'dart:developer' as developer;

import 'package:rice/src/plan_detail/index.dart';
import 'package:meta/meta.dart';
import 'package:rice/src/repository/model/plan.dart';

@immutable
abstract class PlanDetailEvent {
  Future<PlanDetailState> applyAsync(
      {PlanDetailState? currentState, PlanDetailBloc? bloc});
}

class UnPlanDetailEvent extends PlanDetailEvent {
  @override
  Future<PlanDetailState> applyAsync(
      {PlanDetailState? currentState, PlanDetailBloc? bloc}) async {
    return UnPlanDetailState(0);
  }
}

class DeletePlanEvent extends PlanDetailEvent {
  final String? planId;

  DeletePlanEvent({required this.planId});

  @override
  Future<PlanDetailState> applyAsync({
    PlanDetailState? currentState,
    PlanDetailBloc? bloc,
  }) async {
    await bloc!.deletePlan(planId: this.planId);

    return PlanDeletedState(0);
  }
}

class LoadPlanDetailEvent extends PlanDetailEvent {
  final bool isNeededLoad;
  final Plan? plan;
  @override
  String toString() => 'LoadPlanDetailEvent';

  LoadPlanDetailEvent(this.isNeededLoad, {this.plan});

  @override
  Future<PlanDetailState> applyAsync(
      {PlanDetailState? currentState, PlanDetailBloc? bloc}) async {
    try {
      final currentUser = await bloc!.getCurrentUser();
      if (isNeededLoad) {
        final Plan plan = await bloc.getPlan(planId: this.plan!.id);
        return InPlanDetailState(currentState!.version + 1, plan, currentUser: currentUser);
      } else {
        return InPlanDetailState(0, this.plan, currentUser: currentUser);
      }
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadPlanDetailEvent', error: _, stackTrace: stackTrace);
      return ErrorPlanDetailState(0, _.toString());
    }
  }
}

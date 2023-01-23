import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../repository/model/plan.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';

class PlanDetailBloc extends BaseBloc<PlanDetailEvent, PlanDetailState> {
  PlanDetailBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository, initialState: UnPlanDetailState(0));

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  Future<User> getCurrentUser() {
    return this.riceRepository.getCurrentUser();
  }

  Future<void> deletePlan({required String? planId}) {
    return this.riceRepository.deletePlan(planId);
  }

  Future<Plan> getPlan({required String? planId}) {
    return this.riceRepository.fetchPlan(planId);
  }

  @override
  Future<void> mapEventToState(
    PlanDetailEvent event,
    Emitter<PlanDetailState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'PlanDetailBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../repository/model/plan.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';

class CreatePlanBloc extends BaseBloc<CreatePlanEvent, CreatePlanState> {
  CreatePlanBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository, initialState: InCreatePlanState(0));

  Future<String?> createPlan(Plan plan) async {
    return riceRepository.createPlan(plan);
  }

  Future<Plan> updatePlan(Plan plan) async {
    return riceRepository.updatePlan(plan);
  }

  Future<User> findCurrentUser() {
    return this.riceRepository.getCurrentUser();
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  @override
  Future<void> mapEventToState(
    CreatePlanEvent event,
    Emitter<CreatePlanState> emitter,
  ) async {
    try {
      emitter(await (event.applyAsync(currentState: state, bloc: this)
          as FutureOr<CreatePlanState>));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'CreatePlanBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

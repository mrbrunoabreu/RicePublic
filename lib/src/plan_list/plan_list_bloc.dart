import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/model/plan.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';

import '../base_bloc.dart';

class PlanListBloc extends BaseBloc<PlanListEvent, PlanListState> {
  PlanListBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnPlanListState(0));

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  Future<User> getUser() {
    return riceRepository.getCurrentUser();
  }

  Future<List<Plan>> fetchPlans() async {
    DateTime now = DateTime.now();

    final user = await this.getUser();

    return riceRepository.findPlans(
      userId: user.id,
      dateFrom: now,
    );
  }

  Future<List<Plan>> findFriendsPlans() async {
    return riceRepository.findFriendsPlans();
  }

  @override
  Future<void> mapEventToState(
    PlanListEvent event,
    Emitter<PlanListState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'PlanListBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

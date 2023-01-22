import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/explore_plans/explore_plans_event.dart';
import 'package:rice/src/explore_plans/explore_plans_state.dart';
import 'package:rice/src/repository/model/plan.dart';
import 'package:rice/src/repository/rice_repository.dart';

import '../base_bloc.dart';

class ExplorePlansBloc extends BaseBloc<ExplorePlansEvent, ExplorePlansState> {
  ExplorePlansBloc({required RiceRepository riceRepository}) 
    : super(riceRepository: riceRepository, initialState: UnExplorePlansState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<Plan>> fetchPublicPlans(
    double currentLat,
    double currentLng,
  ) async {
    return riceRepository.publicPlansByLocation(currentLat, currentLng);
  }

  @override
  Future<void> mapEventToState(
    ExplorePlansEvent event,
    Emitter<ExplorePlansState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ExplorePlansBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

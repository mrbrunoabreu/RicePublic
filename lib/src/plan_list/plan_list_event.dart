import 'dart:async';
import 'dart:developer' as developer;

import 'index.dart';
import 'package:meta/meta.dart';
import '../repository/model/plan.dart';
import '../repository/model/user.dart';

@immutable
abstract class PlanListEvent {
  Future<PlanListState> applyAsync(
      {PlanListState? currentState, PlanListBloc? bloc});
}

class UnPlanListEvent extends PlanListEvent {
  @override
  Future<PlanListState> applyAsync(
      {PlanListState? currentState, PlanListBloc? bloc}) async {
    return UnPlanListState(0);
  }
}

class LoadPlanListEvent extends PlanListEvent {
  final bool isError;
  final String? datetime;
  @override
  String toString() => 'LoadPlanListEvent';

  LoadPlanListEvent(this.isError, {this.datetime});

  @override
  Future<PlanListState> applyAsync(
      {PlanListState? currentState, PlanListBloc? bloc}) async {
    try {
      if (currentState is InPlanListState) {
        return currentState.getNewVersion();
      }
      String? date = datetime;

      if (datetime == null) {
        date = DateTime.now().toIso8601String();
      }

      final friendsPlans = await bloc!.findFriendsPlans();
      final myPlans = await bloc.fetchPlans();

      final List<Plan> allPlans = List.of(friendsPlans)..addAll(myPlans);

      return InPlanListState(
        0,
        friendsPlans: friendsPlans,
        myPlans: myPlans,
        allPlans: allPlans,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadPlanListEvent', error: _, stackTrace: stackTrace);
      return ErrorPlanListState(0, _.toString());
    }
  }
}

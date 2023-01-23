import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import '../explore/index.dart';
import 'package:meta/meta.dart';
import 'explore_plans_bloc.dart';
import 'explore_plans_state.dart';

import '../utils.dart';

@immutable
abstract class ExplorePlansEvent {
  Future<Position> loadUserLocation() async {
    return await loadUserLastLocation();
  }

  Future<ExplorePlansState> applyAsync(
      {ExplorePlansState? currentState, ExplorePlansBloc? bloc});
}

class UnExplorePlansEvent extends ExplorePlansEvent {
  @override
  Future<ExplorePlansState> applyAsync(
      {ExplorePlansState? currentState, ExplorePlansBloc? bloc}) async {
    return UnExplorePlansState(0);
  }
}

class LoadExplorePlansEvent extends ExplorePlansEvent {
  @override
  String toString() => 'LoadExplorePlansEvent';

  LoadExplorePlansEvent();

  @override
  Future<ExplorePlansState> applyAsync(
      {ExplorePlansState? currentState, ExplorePlansBloc? bloc}) async {
    try {
      if (currentState is InExplorePlansState) {
        return currentState.getNewVersion();
      }

      Position position = await loadUserLocation();

      // await Future.delayed(Duration(seconds: 2));

      var plans = await bloc!.fetchPublicPlans(
        position.latitude,
        position.longitude,
      );

      return InExplorePlansState(
        0,
        plans: plans,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadExplorePlansEvent', error: _, stackTrace: stackTrace);
      return ErrorExplorePlansState(0, _.toString());
    }
  }
}

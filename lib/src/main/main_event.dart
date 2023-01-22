import 'dart:async';
import 'dart:developer' as developer;

import '../main/index.dart';
import 'package:meta/meta.dart';
import '../repository/rice_repository.dart';

@immutable
abstract class MainEvent {
  Future<MainState> applyAsync({MainState? currentState, MainBloc? bloc});
  final RiceRepository _mainRepository = RiceRepositoryImpl();
}

class UnMainEvent extends MainEvent {
  @override
  Future<MainState> applyAsync(
      {MainState? currentState, MainBloc? bloc}) async {
    return UnMainState(0);
  }
}

class LoadMainEvent extends MainEvent {
  final bool isError;
  @override
  String toString() => 'LoadMainEvent';

  LoadMainEvent(this.isError);

  @override
  Future<MainState> applyAsync(
      {MainState? currentState, MainBloc? bloc}) async {
    try {
      if (currentState is InMainState) {
        return currentState.getNewVersion();
      }
      await Future.delayed(Duration(seconds: 2));
      // this._mainRepository.test(this.isError);
      return InMainState(0, "Hello world");
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadMainEvent', error: _, stackTrace: stackTrace);
      return ErrorMainState(0, _.toString());
    }
  }
}

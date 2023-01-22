import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import '../main/index.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(UnMainState(0)) {
    on<MainEvent>(mapEventToState);
  }

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<void> mapEventToState(
    MainEvent event,
    Emitter<MainState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_', name: 'MainBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

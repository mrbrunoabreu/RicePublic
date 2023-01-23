import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_guests_event.dart';
import 'add_guests_state.dart';
import '../base_bloc.dart';
import '../repository/model/user.dart';

import '../repository/rice_repository.dart';

class AddGuestsBloc extends BaseBloc<AddGuestsEvent, AddGuestsState> {
  AddGuestsBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository, initialState: UnAddGuestsState(0));

  Future<List<User>> getFriends(String name) async {
    return riceRepository.findUserByName(name);
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  @override
  Future<void> mapEventToState(
      AddGuestsEvent event, Emitter<AddGuestsState> emitter) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'AddGuestsBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

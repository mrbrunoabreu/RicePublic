import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_personal_list_event.dart';
import 'create_personal_list_state.dart';
import '../repository/model/profile.dart';
import '../repository/rice_repository.dart';

import '../base_bloc.dart';

class CreatePersonalListBloc
    extends BaseBloc<CreatePersonalListEvent, CreatePersonalListState> {
  CreatePersonalListBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: InCreatePersonalListState(0));

  Future<void> savePersonalList({required CreatePersonalList personalList}) {
    return this.riceRepository.savePersonalList(personalList: personalList);
  }

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  @override
  Future<void> mapEventToState(
    CreatePersonalListEvent event,
    Emitter<CreatePersonalListState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'CreatePersonalListBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

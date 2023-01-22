import 'package:flutter/foundation.dart';
import 'package:rice/src/create_personal_list/create_personal_list_bloc.dart';
import 'package:rice/src/create_personal_list/create_personal_list_state.dart';
import 'package:rice/src/repository/model/profile.dart';

@immutable
abstract class CreatePersonalListEvent {
  Future<CreatePersonalListState> applyAsync(
      {CreatePersonalListState? currentState, CreatePersonalListBloc? bloc});
  // final ProfileRepository _profileRepository = ProfileRepository();
}

class InCreatePersonalListEvent extends CreatePersonalListEvent {
  InCreatePersonalListEvent();

  @override
  Future<CreatePersonalListState> applyAsync({
    CreatePersonalListState? currentState,
    CreatePersonalListBloc? bloc,
  }) async {
    return InCreatePersonalListState(0);
  }
}

class SavingPersonalListEvent extends CreatePersonalListEvent {
  SavingPersonalListEvent();

  @override
  Future<CreatePersonalListState> applyAsync({
    CreatePersonalListState? currentState,
    CreatePersonalListBloc? bloc,
  }) async {
    return SavingPersonalListState(0);
  }
}

class SavePersonalListEvent extends CreatePersonalListEvent {
  final CreatePersonalList personalList;

  SavePersonalListEvent({required this.personalList});

  @override
  Future<CreatePersonalListState> applyAsync({
    CreatePersonalListState? currentState,
    CreatePersonalListBloc? bloc,
  }) async {
    await bloc!.savePersonalList(personalList: this.personalList);

    return SavedPersonalListState(0);
  }
}

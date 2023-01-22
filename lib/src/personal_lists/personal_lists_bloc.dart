import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/personal_lists/personal_lists_event.dart';
import 'package:rice/src/personal_lists/personal_lists_state.dart';
import 'package:rice/src/repository/model/profile.dart';
import 'package:rice/src/repository/model/restaurant.dart';
import 'package:rice/src/repository/rice_repository.dart';

import '../base_bloc.dart';

class PersonalListsBloc
    extends BaseBloc<PersonalListsEvent, PersonalListsState> {
  PersonalListsBloc({required RiceRepository riceRepository}) 
    : super(riceRepository: riceRepository, initialState: UnPersonalListsState(0));

  Future<List<ListMetadata>> findPersonalLists({required String? userId}) {
    return this.riceRepository.findPersonalLists(userId: userId);
  }

  Future<void> addRestaurantToList({Restaurant? restaurant, String? listId}) {
    return this.riceRepository.addRestaurantToMyLists(
          restaurant,
          listId,
          false,
        );
  }

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  @override
  Future<void> mapEventToState(
    PersonalListsEvent event,
    Emitter<PersonalListsState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'PersonalListsBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

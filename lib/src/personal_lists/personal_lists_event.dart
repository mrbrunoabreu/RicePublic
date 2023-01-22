import 'dart:async';
import 'dart:developer' as developer;

import 'package:rice/src/base_bloc.dart';
import 'package:rice/src/personal_lists/personal_lists_bloc.dart';
import 'package:rice/src/personal_lists/personal_lists_state.dart';
import 'package:meta/meta.dart';
import 'package:rice/src/personal_restaurants/personal_restaurants_event.dart';
import 'package:rice/src/repository/model/personal_list.dart';
import 'package:rice/src/repository/model/profile.dart';
import 'package:rice/src/repository/model/restaurant.dart';

@immutable
abstract class PersonalListsEvent {
  Future<PersonalListsState> applyAsync(
      {PersonalListsState? currentState, PersonalListsBloc? bloc});
}

class UnPersonalListsEvent extends PersonalListsEvent with NeedShowLoader {
  @override
  Future<PersonalListsState> applyAsync(
      {PersonalListsState? currentState, PersonalListsBloc? bloc}) async {
    return UnPersonalListsState(0);
  }
}

class LoadPersonalListsEvent extends PersonalListsEvent {
  final String? userId;

  LoadPersonalListsEvent({this.userId});

  @override
  Future<PersonalListsState> applyAsync({
    PersonalListsState? currentState,
    PersonalListsBloc? bloc,
  }) async {
    final personalLists = await (this.userId != null
        ? bloc!.findPersonalLists(userId: this.userId)
        : Future<List<ListMetadata>>.value([]));

    return InPersonalListsState(0, personalLists: personalLists);
  }
}

class AddRestaurantToListEvent extends PersonalListsEvent {
  final Restaurant? restaurant;
  final String? listId;

  AddRestaurantToListEvent({required this.restaurant, required this.listId});

  @override
  Future<PersonalListsState> applyAsync({
    PersonalListsState? currentState,
    PersonalListsBloc? bloc,
  }) async {
    await bloc!.addRestaurantToList(restaurant: restaurant, listId: listId);

    return AddedRestaurantToListState(
      0,
      personalLists: currentState is InPersonalListsState
          ? currentState.personalLists
          : [],
    );
  }
}

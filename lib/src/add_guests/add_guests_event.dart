import 'dart:async';
import 'dart:developer' as developer;

import 'add_guests_bloc.dart';
import 'add_guests_state.dart';
import 'package:meta/meta.dart';
import '../repository/model/profile.dart';
import '../repository/model/user.dart';

@immutable
abstract class AddGuestsEvent {
  Future<AddGuestsState> applyAsync(
      {AddGuestsState? currentState, AddGuestsBloc? bloc});
}

class UnAddGuestsEvent extends AddGuestsEvent {
  @override
  Future<AddGuestsState> applyAsync(
      {AddGuestsState? currentState, AddGuestsBloc? bloc}) async {
    return UnAddGuestsState(0);
  }
}

class LoadAddGuestsEvent extends AddGuestsEvent {
  final bool isError;
  @override
  String toString() => 'LoadAddGuestsEvent';

  LoadAddGuestsEvent(this.isError);

  @override
  Future<AddGuestsState> applyAsync(
      {AddGuestsState? currentState, AddGuestsBloc? bloc}) async {
    try {
      if (currentState is InAddGuestsState) {
        return currentState.getNewVersion();
      }
      List<User> friends = await bloc!.getFriends('');
      return InAddGuestsState(0, friends);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadCreatePlanEvent', error: _, stackTrace: stackTrace);
      return ErrorAddGuestsState(0, _!.toString());
    }
  }
}

class SearchFriendsEvent extends AddGuestsEvent {
  final String name;

  SearchFriendsEvent({required this.name});

  @override
  String toString() => 'SearchFriendsEvent';

  @override
  Future<AddGuestsState> applyAsync(
      {AddGuestsState? currentState, AddGuestsBloc? bloc}) async {
    try {
      List<User> friends = await bloc!.getFriends(this.name);

      return InAddGuestsState(0, friends);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'UploadProfileEvent', error: _, stackTrace: stackTrace);
      return ErrorAddGuestsState(0, _!.toString());
    }
  }
}

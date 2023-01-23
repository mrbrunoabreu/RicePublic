import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'follow_list_event.dart';
import 'follow_list_state.dart';
import 'dart:developer' as developer;

import '../repository/model/profile.dart';
import '../repository/rice_repository.dart';

class FollowListBloc extends BaseBloc<FollowListEvent, FollowListState> {
  FollowListBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository, initialState: UnFollowListState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<Profile>> findUserById({required List<String>? userIds}) {
    return this.riceRepository.findProfiles(users: userIds);
  }

  @override
  Future<void> mapEventToState(
    FollowListEvent event,
    Emitter<FollowListState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ProfileBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

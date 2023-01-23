import 'package:flutter/material.dart';
import 'follow_list_bloc.dart';
import 'follow_list_state.dart';
import '../repository/model/profile.dart';
import '../utils.dart';
import 'package:tuple/tuple.dart';

@immutable
abstract class FollowListEvent {
  Future<FollowListState> applyAsync(
      {FollowListState? currentState, FollowListBloc? bloc});
}

class UnFollowListEvent extends FollowListEvent {
  @override
  Future<FollowListState> applyAsync(
      {FollowListState? currentState, FollowListBloc? bloc}) async {
    return UnFollowListState(0);
  }
}

class LoadFollowListEvent extends FollowListEvent {
  final List<String>? userIds;

  LoadFollowListEvent({this.userIds});

  @override
  Future<FollowListState> applyAsync({
    FollowListState? currentState,
    FollowListBloc? bloc,
  }) async {
    try {
      if (this.userIds != null && this.userIds!.isNotEmpty) {
        final List<Profile> list = await bloc!.findUserById(userIds: userIds);

        final List<Tuple2<String, Profile>> idProfileList =
            mapIndexed<Tuple2<String, Profile>, Profile>(list,
                    (index, e) => Tuple2<String, Profile>(userIds![index], e))
                .toList();

        return InFollowListState(0, userList: idProfileList);
      } else {
        return InFollowListState(0, userList: []);
      }
    } catch (_, stackTrace) {
      return ErrorFollowListState(0, '');
    }
  }
}

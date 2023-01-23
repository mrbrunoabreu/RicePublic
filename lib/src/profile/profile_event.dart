import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:geolocator/geolocator.dart';
import 'index.dart';
import 'package:meta/meta.dart';
import '../repository/model/profile.dart';
import '../repository/model/user.dart';
import '../utils.dart';

@immutable
abstract class ProfileEvent {
  Future<Position> loadUserLocation() async {
    return await loadUserLastLocation();
  }

  Future<ProfileState> applyAsync(
      {ProfileState? currentState, ProfileBloc? bloc});
  // final ProfileRepository _profileRepository = ProfileRepository();
}

class UnProfileEvent extends ProfileEvent {
  @override
  Future<ProfileState> applyAsync(
      {ProfileState? currentState, ProfileBloc? bloc}) async {
    return UnProfileState(0);
  }
}

class LoadProfileEvent extends ProfileEvent {
  final String? userId;

  final bool isError;

  @override
  String toString() => 'LoadProfileEvent';

  LoadProfileEvent(
    this.isError, {
    required this.userId,
  });

  @override
  Future<ProfileState> applyAsync(
      {ProfileState? currentState, ProfileBloc? bloc}) async {
    try {
      if (currentState is InProfileState) {
        return currentState.getNewVersion();
      }

      User user = await bloc!.getUser();
      final Profile profile = await bloc.findProfile(
        userId: this.userId != null ? this.userId : user.id,
      );

      if (profile.followers != null && profile.followers!.isNotEmpty) {
        String? following = profile.followers!
            .firstWhereOrNull((element) => element == user.id);
        if (following != null) {
          profile.isFollowedByUser = true;
        }
      }

      return InProfileState(
        0,
        profile,
        currentUser: user,
        upcomingPlans: null,
        reviews: null,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadProfileEvent', error: _, stackTrace: stackTrace);
      return ErrorProfileState(0, _.toString());
    }
  }
}

class ToggleFriendshipEvent extends ProfileEvent {
  final String? userId;

  ToggleFriendshipEvent({required this.userId}) {}

  @override
  Future<ProfileState> applyAsync({
    ProfileState? currentState,
    ProfileBloc? bloc,
  }) async {
    if (currentState is InProfileState) {
      currentState.profile.isFollowedByUser!
          ? await bloc!.toggleUnfollowing(userId: this.userId)
          : await bloc!.toggleFollowing(userId: this.userId);

      currentState.profile.isFollowedByUser =
          !currentState.profile.isFollowedByUser!;

      return InProfileState(
        currentState.version + 1,
        currentState.profile,
        currentUser: currentState.currentUser,
        upcomingPlans: bloc.findPlans(
          this.userId,
          DateTime.now(),
        ),
        reviews: bloc.findReviews(this.userId),
      );
    }

    return ErrorProfileState(0, 'Incorrect State');
  }
}

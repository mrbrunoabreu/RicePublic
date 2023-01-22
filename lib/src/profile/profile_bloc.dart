import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/profile/index.dart';
import '../repository/model/chat.dart';
import '../repository/model/profile.dart';
import '../repository/model/review.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';

import '../base_bloc.dart';

class ProfileBloc extends BaseBloc<ProfileEvent, ProfileState> {
  ProfileBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnProfileState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<User> getUser() {
    return riceRepository.getCurrentUser();
  }

  Future<ChatMetadata> startChat(User user) {
    return riceRepository.startChat(user: user);
  }

  Future<Profile> findProfile({required String? userId}) {
    return riceRepository.findProfile(
      userId: userId,
    );
  }

  Future<void> toggleFollowing({required String? userId}) {
    return riceRepository.toggleFollowing(userId: userId);
  }

  Future<void> toggleUnfollowing({required String? userId}) {
    return riceRepository.toggleUnfollowing(userId: userId);
  }

  Future<List<dynamic>> findPlans(String? userId, DateTime dateFrom) {
    return riceRepository.findPlans(userId: userId, dateFrom: dateFrom);
  }

  Future<List<Review>> findReviews(String? userId) {
    return riceRepository
        .findReviews(userId: userId)
        .then((value) => value as List<Review>);
  }

  Future<String?> getCurrentPlace(double lat, double lng) {
    return riceRepository.getLocationName(lat, lng);
  }

  @override
  Future<void> mapEventToState(
    ProfileEvent event,
    Emitter<ProfileState> emitter,
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

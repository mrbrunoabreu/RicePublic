import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'index.dart';
import 'package:meta/meta.dart';
import '../repository/model/profile.dart';

@immutable
abstract class EditProfileEvent {
  Future<EditProfileState> applyAsync(
      {EditProfileState? currentState, EditProfileBloc? bloc});
}

class UnEditProfileEvent extends EditProfileEvent {
  @override
  Future<EditProfileState> applyAsync(
      {EditProfileState? currentState, EditProfileBloc? bloc}) async {
    return UnEditProfileState(0);
  }
}

class LoadEditProfileEvent extends EditProfileEvent {
  final bool isError;
  @override
  String toString() => 'LoadEditProfileEvent';

  LoadEditProfileEvent(this.isError);

  @override
  Future<EditProfileState> applyAsync(
      {EditProfileState? currentState, EditProfileBloc? bloc}) async {
    try {
      if (currentState is InEditProfileState) {
        return currentState.getNewVersion();
      }
      Profile profile = await bloc!.loadCurrentUserProfile();
      // await Future.delayed(Duration(seconds: 2));
      // this._EditProfileRepository.test(this.isError);
      return InEditProfileState(0, profile);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadEditProfileEvent', error: _, stackTrace: stackTrace);
      return ErrorEditProfileState(0, _.toString());
    }
  }
}

class UploadProfileEvent extends EditProfileEvent {
  final Profile? profile;
  final File? imageFile;

  @override
  String toString() => 'UploadProfileEvent';

  UploadProfileEvent(this.profile, {this.imageFile});

  @override
  Future<EditProfileState> applyAsync(
      {EditProfileState? currentState, EditProfileBloc? bloc}) async {
    try {
      bool isLoggedIn = await bloc!.attemptLogin();
      if (!isLoggedIn) {
        throw StateError('Not logged In yet');
      }
      Profile profile;
      if (imageFile != null) {
        profile = await bloc.uploadProfileAndPicture(this.profile, imageFile);
      } else {
        profile = await bloc.uploadProfile(this.profile);
      }
      return InEditProfileState(
        0,
        profile,
        hasUpdatedProfile: true,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'UploadProfileEvent', error: _, stackTrace: stackTrace);
      return ErrorEditProfileState(0, _.toString());
    }
  }
}

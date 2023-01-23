import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/model/profile.dart';

import '../base_bloc.dart';
import '../repository/rice_repository.dart';

class EditProfileBloc extends BaseBloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnEditProfileState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<Profile> loadCurrentUserProfile() {
    return riceRepository.getCurrentUser().then((value) => value.profile!);
  }

  Future<Profile> uploadProfilePicture(File file) {
    return riceRepository.updateProfilePicture(file);
  }

  Future<Profile> uploadProfile(Profile? profile) {
    return riceRepository.updateProfile(profile);
  }

  Future<Profile> uploadProfileAndPicture(Profile? profile, File? file) {
    return riceRepository.updateProfileAndProfilePicture(profile, file);
  }

  @override
  Future<void> mapEventToState(
    EditProfileEvent event,
    Emitter<EditProfileState> emitter,
  ) async {
    try {
      emitter(UnEditProfileState(1));
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'EditProfileBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

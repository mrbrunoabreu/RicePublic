import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/profile.dart';

abstract class EditProfileState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  EditProfileState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  EditProfileState getStateCopy();

  EditProfileState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnEditProfileState extends EditProfileState with NeedShowLoader {
  UnEditProfileState(int version) : super(version);

  @override
  String toString() => 'UnEditProfileState';

  @override
  UnEditProfileState getStateCopy() {
    return UnEditProfileState(0);
  }

  @override
  UnEditProfileState getNewVersion() {
    return UnEditProfileState(version + 1);
  }
}

/// Initialized
class InEditProfileState extends EditProfileState {
  final Profile profile;

  final bool hasUpdatedProfile;

  InEditProfileState(int version, this.profile,
      {this.hasUpdatedProfile = false})
      : super(version, [profile]);

  @override
  String toString() => 'InEditProfileState $profile';

  @override
  InEditProfileState getStateCopy() {
    return InEditProfileState(this.version, this.profile);
  }

  @override
  InEditProfileState getNewVersion() {
    return InEditProfileState(version + 1, this.profile);
  }
}

class ErrorEditProfileState extends EditProfileState {
  final String errorMessage;

  ErrorEditProfileState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorEditProfileState';

  @override
  ErrorEditProfileState getStateCopy() {
    return ErrorEditProfileState(this.version, this.errorMessage);
  }

  @override
  ErrorEditProfileState getNewVersion() {
    return ErrorEditProfileState(version + 1, this.errorMessage);
  }
}

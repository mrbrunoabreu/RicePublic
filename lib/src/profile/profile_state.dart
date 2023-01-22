import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import '../repository/model/profile.dart';
import '../repository/model/user.dart';

abstract class ProfileState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ProfileState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ProfileState getStateCopy();

  ProfileState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnProfileState extends ProfileState with NeedShowLoader {
  UnProfileState(int version) : super(version);

  @override
  String toString() => 'UnProfileState';

  @override
  UnProfileState getStateCopy() {
    return UnProfileState(0);
  }

  @override
  UnProfileState getNewVersion() {
    return UnProfileState(version + 1);
  }
}

/// Initialized
class InProfileState extends ProfileState {
  final User currentUser;
  final Profile profile;

  final Future<List<dynamic>>? upcomingPlans;
  final Future<List<dynamic>>? reviews;

  InProfileState(
    int version,
    this.profile, {
    required this.currentUser,
    required this.upcomingPlans,
    required this.reviews,
  }) : super(version, [Profile, currentUser, upcomingPlans]);

  @override
  String toString() => 'InProfileState $profile';

  @override
  InProfileState getStateCopy() {
    return InProfileState(
      this.version,
      this.profile,
      currentUser: this.currentUser,
      upcomingPlans: this.upcomingPlans,
      reviews: this.reviews,
    );
  }

  @override
  InProfileState getNewVersion() {
    return InProfileState(
      version + 1,
      this.profile,
      currentUser: this.currentUser,
      upcomingPlans: this.upcomingPlans,
      reviews: this.reviews,
    );
  }
}

class ErrorProfileState extends ProfileState {
  final String errorMessage;

  ErrorProfileState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorProfileState';

  @override
  ErrorProfileState getStateCopy() {
    return ErrorProfileState(this.version, this.errorMessage);
  }

  @override
  ErrorProfileState getNewVersion() {
    return ErrorProfileState(version + 1, this.errorMessage);
  }
}

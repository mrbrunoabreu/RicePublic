import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SettingsEvent {
  Future<SettingsState> applyAsync(
      {SettingsState? currentState, SettingsBloc? bloc});
}

class UnSettingsEvent extends SettingsEvent {
  @override
  Future<SettingsState> applyAsync(
      {SettingsState? currentState, SettingsBloc? bloc}) async {
    return UnSettingsState(0);
  }
}

class LogoutEvent extends SettingsEvent {
  @override
  Future<SettingsState> applyAsync(
      {SettingsState? currentState, SettingsBloc? bloc}) async {
    await bloc!.logout();
    return LoggedOutProfileState(0);
  }
}

class LoadSettingsEvent extends SettingsEvent {
  final bool isError;
  @override
  String toString() => 'LoadSettingsEvent';

  LoadSettingsEvent(this.isError);

  @override
  Future<SettingsState> applyAsync(
      {SettingsState? currentState, SettingsBloc? bloc}) async {
    try {
      if (currentState is InSettingsState) {
        return currentState.getNewVersion();
      }
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      // await Future.delayed(Duration(seconds: 2));
      // this._settingsRepository.test(this.isError);
      return InSettingsState(0, isServiceEnabled);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadSettingsEvent', error: _, stackTrace: stackTrace);
      return ErrorSettingsState(0, _.toString());
    }
  }
}

class ChangePasswordEvent extends SettingsEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  Future<SettingsState> applyAsync(
      {SettingsState? currentState, SettingsBloc? bloc}) async {
    try {
      await bloc!.changePassword(
        currentPassword: this.currentPassword,
        newPassword: this.newPassword,
      );
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      return PasswordChangedState(
        1,
        isServiceEnabled,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadSettingsEvent', error: _, stackTrace: stackTrace);
      return ErrorSettingsState(0, 'Current password doesn\'t match');
    }
  }
}

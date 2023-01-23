import 'package:equatable/equatable.dart';
import '../base_bloc.dart';

abstract class SettingsState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  SettingsState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  SettingsState getStateCopy();

  SettingsState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnSettingsState extends SettingsState with NeedShowLoader {
  UnSettingsState(int version) : super(version);

  @override
  String toString() => 'UnSettingsState';

  @override
  UnSettingsState getStateCopy() {
    return UnSettingsState(0);
  }

  @override
  UnSettingsState getNewVersion() {
    return UnSettingsState(version + 1);
  }
}

/// Initialized
class InSettingsState extends SettingsState {
  bool isServiceEnabled;

  InSettingsState(
    int version,
    this.isServiceEnabled,
  ) : super(version, [isServiceEnabled]);

  @override
  String toString() => 'InSettingsState';

  @override
  InSettingsState getStateCopy() {
    return InSettingsState(
      this.version,
      this.isServiceEnabled,
    );
  }

  @override
  InSettingsState getNewVersion() {
    return InSettingsState(
      version + 1,
      this.isServiceEnabled,
    );
  }
}

/// LoggedOut
class LoggedOutProfileState extends SettingsState {
  LoggedOutProfileState(int version) : super(version);

  @override
  String toString() => 'LoggedOutProfileState';

  @override
  LoggedOutProfileState getStateCopy() {
    return LoggedOutProfileState(0);
  }

  @override
  LoggedOutProfileState getNewVersion() {
    return LoggedOutProfileState(version + 1);
  }
}

class ErrorSettingsState extends SettingsState {
  final String errorMessage;

  ErrorSettingsState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorSettingsState';

  @override
  ErrorSettingsState getStateCopy() {
    return ErrorSettingsState(this.version, this.errorMessage);
  }

  @override
  ErrorSettingsState getNewVersion() {
    return ErrorSettingsState(version + 1, this.errorMessage);
  }
}

class PasswordChangedState extends InSettingsState {
  PasswordChangedState(
    int version,
    bool isServiceEnabled,
  ) : super(version, isServiceEnabled);

  @override
  String toString() => 'PasswordChangedState';

  @override
  PasswordChangedState getStateCopy() {
    return PasswordChangedState(
      this.version,
      this.isServiceEnabled,
    );
  }

  @override
  PasswordChangedState getNewVersion() {
    return PasswordChangedState(
      version + 1,
      this.isServiceEnabled,
    );
  }
}

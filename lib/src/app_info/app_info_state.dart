import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import 'package:version/version.dart';

abstract class AppInfoState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  AppInfoState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  AppInfoState getStateCopy();

  AppInfoState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

/// UnInitialized
class UnAppInfoState extends AppInfoState with NeedShowLoader {
  UnAppInfoState(int version) : super(version);

  @override
  String toString() => 'UnAppInfoState';

  @override
  UnAppInfoState getStateCopy() {
    return UnAppInfoState(0);
  }

  @override
  UnAppInfoState getNewVersion() {
    return UnAppInfoState(version + 1);
  }
}

/// Initialized
class InAppInfoState extends AppInfoState {
  Version appVersion;

  InAppInfoState(int version, this.appVersion) : super(version, [appVersion]);

  @override
  String toString() => 'InAppInfoState $version';

  @override
  InAppInfoState getStateCopy() {
    return InAppInfoState(this.version, this.appVersion);
  }

  @override
  InAppInfoState getNewVersion() {
    return InAppInfoState(version + 1, this.appVersion);
  }
}

class ErrorAppInfoState extends AppInfoState {
  final String? errorMessage;

  ErrorAppInfoState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorAppInfoState';

  @override
  ErrorAppInfoState getStateCopy() {
    return ErrorAppInfoState(this.version, this.errorMessage);
  }

  @override
  ErrorAppInfoState getNewVersion() {
    return ErrorAppInfoState(version + 1, this.errorMessage);
  }
}

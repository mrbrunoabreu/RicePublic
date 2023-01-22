import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/editorial.dart';

abstract class ResetPasswordState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ResetPasswordState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ResetPasswordState getStateCopy();

  ResetPasswordState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

/// UnInitialized
class UnResetPasswordState extends ResetPasswordState with NeedShowLoader {
  UnResetPasswordState(int version) : super(version);

  @override
  String toString() => 'UnResetPasswordState';

  @override
  UnResetPasswordState getStateCopy() {
    return UnResetPasswordState(0);
  }

  @override
  UnResetPasswordState getNewVersion() {
    return UnResetPasswordState(version + 1);
  }
}

/// Initialized
class InResetPasswordState extends ResetPasswordState {
  final String? token;

  InResetPasswordState(int version, this.token) : super(version, [token]);

  @override
  String toString() => 'InResetPasswordState $token';

  @override
  InResetPasswordState getStateCopy() {
    return InResetPasswordState(this.version, this.token);
  }

  @override
  InResetPasswordState getNewVersion() {
    return InResetPasswordState(version + 1, this.token);
  }
}

class DoneResetPasswordState extends ResetPasswordState {
  DoneResetPasswordState(int version) : super(version, []);

  @override
  String toString() => 'InResetPasswordState';

  @override
  DoneResetPasswordState getStateCopy() {
    return DoneResetPasswordState(this.version);
  }

  @override
  DoneResetPasswordState getNewVersion() {
    return DoneResetPasswordState(version + 1);
  }
}

class ErrorResetPasswordState extends ResetPasswordState {
  final String? errorMessage;

  ErrorResetPasswordState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorResetPasswordState';

  @override
  ErrorResetPasswordState getStateCopy() {
    return ErrorResetPasswordState(this.version, this.errorMessage);
  }

  @override
  ErrorResetPasswordState getNewVersion() {
    return ErrorResetPasswordState(version + 1, this.errorMessage);
  }
}

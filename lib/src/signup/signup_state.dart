import 'package:equatable/equatable.dart';
import '../base_bloc.dart';

abstract class SignUpState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  SignUpState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  SignUpState getStateCopy();

  SignUpState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

/// UnInitialized
class UnSignUpState extends SignUpState with NeedShowLoader {
  UnSignUpState(int version) : super(version);

  @override
  String toString() => 'UnSignUpState';

  @override
  UnSignUpState getStateCopy() {
    return UnSignUpState(0);
  }

  @override
  UnSignUpState getNewVersion() {
    return UnSignUpState(version + 1);
  }
}

/// Initialized
class InSignUpState extends SignUpState {
  final String? token;
  final String? userEmail;

  InSignUpState(int version, this.token, this.userEmail)
      : super(version, [token, userEmail]);

  @override
  String toString() => 'InSignUpState $userEmail';

  @override
  InSignUpState getStateCopy() {
    return InSignUpState(this.version, this.token, this.userEmail);
  }

  @override
  InSignUpState getNewVersion() {
    return InSignUpState(version + 1, this.token, this.userEmail);
  }
}

class DoneSignUpState extends SignUpState {
  DoneSignUpState(int version) : super(version, []);

  @override
  String toString() => 'InSignUpState';

  @override
  DoneSignUpState getStateCopy() {
    return DoneSignUpState(this.version);
  }

  @override
  DoneSignUpState getNewVersion() {
    return DoneSignUpState(version + 1);
  }
}

class ErrorSignUpState extends SignUpState {
  final String? errorMessage;

  ErrorSignUpState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorSignUpState';

  @override
  ErrorSignUpState getStateCopy() {
    return ErrorSignUpState(this.version, this.errorMessage);
  }

  @override
  ErrorSignUpState getNewVersion() {
    return ErrorSignUpState(version + 1, this.errorMessage);
  }
}

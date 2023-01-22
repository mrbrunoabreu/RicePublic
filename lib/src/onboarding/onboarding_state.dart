import 'package:equatable/equatable.dart';
import '../base_bloc.dart';

abstract class OnboardingState extends Equatable with LoaderController {
  final Iterable? propss;
  OnboardingState([this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  OnboardingState getStateCopy();

  @override
  List<Object?> get props => propss as List<Object?>;
}

/// UnInitialized
class UnOnboardingState extends OnboardingState {
  @override
  String toString() => 'UnOnboardingState';

  @override
  UnOnboardingState getStateCopy() {
    return UnOnboardingState();
  }
}

class LoadingOnboardingState extends OnboardingState with NeedShowLoader {
  @override
  String toString() => 'LoadingOnboardingState';

  @override
  LoadingOnboardingState getStateCopy() {
    return LoadingOnboardingState();
  }
}

/// LoggedIn
class LoggedInOnboardingState extends OnboardingState {
  @override
  String toString() => 'LoggedInOnboardingState';

  @override
  LoggedInOnboardingState getStateCopy() {
    return LoggedInOnboardingState();
  }
}

class SentEnrollmentEmailOnboardingState extends OnboardingState {
  @override
  String toString() => 'SentEnrollmentEmailOnboardingState';

  @override
  SentEnrollmentEmailOnboardingState getStateCopy() {
    return SentEnrollmentEmailOnboardingState();
  }
}

/// Initialized
class InOnboardingState extends OnboardingState {
  @override
  String toString() => 'InOnboardingState';

  @override
  InOnboardingState getStateCopy() {
    return InOnboardingState();
  }
}

class SentPasswordRecoveryState extends OnboardingState {
  @override
  String toString() => 'SentPasswordRecoveryState';

  @override
  SentPasswordRecoveryState getStateCopy() {
    return SentPasswordRecoveryState();
  }
}

class SingingUpState extends OnboardingState {
  @override
  String toString() => 'SingingUpState';

  @override
  SingingUpState getStateCopy() {
    return SingingUpState();
  }
}

class ErrorOnboardingState extends OnboardingState {
  final String? errorMessage;
  bool consumed = false;

  ErrorOnboardingState(this.errorMessage) : super([errorMessage]);

  @override
  String toString() => 'ErrorOnboardingState';

  @override
  ErrorOnboardingState getStateCopy() {
    return ErrorOnboardingState(this.errorMessage);
  }
}

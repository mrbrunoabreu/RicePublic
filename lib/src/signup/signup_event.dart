import 'dart:async';
import 'dart:developer' as developer;

import '../signup/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SignUpEvent {
  Future<SignUpState?> applyAsync(
      {SignUpState? currentState, SignUpBloc? bloc});
}

class UnSignUpEvent extends SignUpEvent {
  @override
  Future<SignUpState> applyAsync(
      {SignUpState? currentState, SignUpBloc? bloc}) async {
    return UnSignUpState(0);
  }
}

class LoadSignUpEvent extends SignUpEvent {
  final bool? isError;
  final String? errMsg;
  final String? token;
  final String? userEmail;
  @override
  String toString() => 'LoadSignUpEvent';

  LoadSignUpEvent({this.isError, this.token, this.userEmail, this.errMsg});

  @override
  Future<SignUpState> applyAsync(
      {SignUpState? currentState, SignUpBloc? bloc}) async {
    if (isError!) {
      return ErrorSignUpState(0, errMsg);
    }

    try {
      if (currentState is InSignUpState) {
        return currentState.getNewVersion();
      }

      return InSignUpState(0, token, userEmail);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadSignUpEvent', error: _, stackTrace: stackTrace);
      return ErrorSignUpState(0, _.toString());
    }
  }
}

class DoSignUpEvent extends SignUpEvent {
  final String password;
  @override
  String toString() => 'DoSignUpEvent';

  DoSignUpEvent(this.password);

  @override
  Future<SignUpState?> applyAsync(
      {SignUpState? currentState, SignUpBloc? bloc}) async {
    try {
      if (currentState is InSignUpState) {
        await bloc!.resetPassword(
            currentState.userEmail, currentState.token, password);
        return DoneSignUpState(0);
      }

      return currentState;
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadSignUpEvent', error: _, stackTrace: stackTrace);
      return ErrorSignUpState(0, _.toString());
    }
  }
}

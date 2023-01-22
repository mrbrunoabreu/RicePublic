import 'dart:async';
import 'dart:developer' as developer;

import '../reset_password/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ResetPasswordEvent {
  Future<ResetPasswordState?> applyAsync(
      {ResetPasswordState? currentState, ResetPasswordBloc? bloc});
}

class UnResetPasswordEvent extends ResetPasswordEvent {
  @override
  Future<ResetPasswordState> applyAsync(
      {ResetPasswordState? currentState, ResetPasswordBloc? bloc}) async {
    return UnResetPasswordState(0);
  }
}

class LoadResetPasswordEvent extends ResetPasswordEvent {
  final bool? isError;
  final String? errMsg;
  final String? token;
  @override
  String toString() => 'LoadResetPasswordEvent';

  LoadResetPasswordEvent({this.isError, this.token, this.errMsg});

  @override
  Future<ResetPasswordState> applyAsync(
      {ResetPasswordState? currentState, ResetPasswordBloc? bloc}) async {
    if (isError!) {
      return ErrorResetPasswordState(0, errMsg);
    }

    try {
      if (currentState is InResetPasswordState) {
        return currentState.getNewVersion();
      }

      return InResetPasswordState(0, token);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadResetPasswordEvent', error: _, stackTrace: stackTrace);
      return ErrorResetPasswordState(0, _?.toString());
    }
  }
}

class DoResetPasswordEvent extends ResetPasswordEvent {
  final String password;
  @override
  String toString() => 'DoResetPasswordEvent';

  DoResetPasswordEvent(this.password);

  @override
  Future<ResetPasswordState?> applyAsync(
      {ResetPasswordState? currentState, ResetPasswordBloc? bloc}) async {
    try {
      if (currentState is InResetPasswordState) {
        await bloc!.resetPassword(currentState.token, password);
        return DoneResetPasswordState(0);
      }

      return currentState;
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadResetPasswordEvent', error: _, stackTrace: stackTrace);
      return ErrorResetPasswordState(0, _?.toString());
    }
  }
}

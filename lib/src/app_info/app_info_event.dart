import 'dart:async';
import 'dart:developer' as developer;

import 'package:meta/meta.dart';
import 'index.dart';
import 'package:version/version.dart';

@immutable
abstract class AppInfoEvent {
  Future<AppInfoState> applyAsync(
      {AppInfoState? currentState, AppInfoBloc? bloc});
}

class UnAppInfoEvent extends AppInfoEvent {
  @override
  Future<AppInfoState> applyAsync(
      {AppInfoState? currentState, AppInfoBloc? bloc}) async {
    return UnAppInfoState(0);
  }
}

class LoadAppInfoEvent extends AppInfoEvent {
  final bool? isError;
  final String? errMsg;
  @override
  String toString() => 'LoadAppInfoEvent';

  LoadAppInfoEvent({this.isError, this.errMsg = null});

  @override
  Future<AppInfoState> applyAsync(
      {AppInfoState? currentState, AppInfoBloc? bloc}) async {
    if (isError!) {
      return ErrorAppInfoState(0, errMsg);
    }

    Version version = await bloc!.appVersion();
    try {
      if (currentState is InAppInfoState) {
        return currentState.getNewVersion();
      }

      return InAppInfoState(0, version);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadAppInfoEvent', error: _, stackTrace: stackTrace);
      return ErrorAppInfoState(0, _?.toString());
    }
  }
}

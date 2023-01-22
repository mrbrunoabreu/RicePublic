import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';
import 'dart:developer' as developer;

import '../base_bloc.dart';

class NotificationBloc extends BaseBloc<NotificationEvent, NotificationState> {
  NotificationBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: NotificationInitial());

  Future<String?> registerToken(String? deviceToken, String eId) {
    return riceRepository.registerDeviceToken(
        deviceToken, eId, Platform.isIOS ? DeviceType.iOS : DeviceType.Android);
  }

  unregisterToken(String? deviceToken) {
    riceRepository.unregisterDeviceToken(deviceToken);
  }

  @override
  Future<void> mapEventToState(
      NotificationEvent event, Emitter<NotificationState> emitter) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_', name: 'MainBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

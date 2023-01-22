import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:developer' as developer;

import 'index.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CallbackType { onMessage, onBackgroundMessage, onResume, onLaunch }

@immutable
abstract class NotificationEvent extends Equatable {
  final TAG = "NotificationEvent";
  final String SP_DEVICE_TOKEN = "deviceToken";
  final String SP_PLAYER_ID = "playerId";
  const NotificationEvent();

  @override
  List<Object> get props => [];

  Future<NotificationState> applyAsync(
      {NotificationState? currentState, NotificationBloc? bloc});
}

class SetupFirebaseMessaging extends NotificationEvent {
  @override
  Future<NotificationState> applyAsync(
      {NotificationState? currentState, NotificationBloc? bloc}) async {
    developer.log("SetupFirebaseMessaging: applyAsync called", name: TAG);
    OneSignal.shared.setExternalUserId(bloc!.getCurrentUserId()!);
    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedToken = '';
      String? storedPlayId = '';
      if (prefs.containsKey(SP_DEVICE_TOKEN)) {
        storedToken = prefs.getString(SP_DEVICE_TOKEN);
      }

      if (prefs.containsKey(SP_PLAYER_ID)) {
        storedPlayId = prefs.getString(SP_PLAYER_ID);
      }

      String? token = changes.to.pushToken;
      if (token != null && token.isNotEmpty) {
        if (storedToken != token) {
          await prefs.setString(SP_DEVICE_TOKEN, token);
        }
      }

      String? playerId = changes.to.userId;
      if (playerId != null && playerId.isNotEmpty) {
        if (storedToken != token && storedPlayId != playerId) {
          developer.log(
              "SubscriptionObserver: Registering Token = $token, User ID = $playerId",
              name: TAG);
          bloc.registerToken(token, playerId).then((value) {
            prefs.setString(SP_PLAYER_ID, value!);
          });
        }
      }
      developer.log("SubscriptionObserver: Token = $token, User ID = $playerId",
          name: TAG);
    });
    OneSignal.shared.disablePush(false);
    OneSignal.shared.disablePush(true);

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      bloc.add(CallbackEvent(message: {
        'title': event.notification.title,
        'message': event.notification.body,
        'payload': event.notification.rawPayload
      }, type: CallbackType.onMessage));
    });

    // OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
    //     bloc.add(CallbackEvent(
    //     message: {
    //       'title': notification.payload.title,
    //       'message': notification.payload.body,
    //       'payload': notification.payload
    //     },
    //     type: CallbackType.onMessage
    //   ));
    // });
    return NotificationReady();
  }
}

class TearDownFirebaseMessaging extends NotificationEvent {
  @override
  Future<NotificationState> applyAsync(
      {NotificationState? currentState, NotificationBloc? bloc}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(SP_DEVICE_TOKEN)) {
      String? token = await prefs.getString(SP_DEVICE_TOKEN);
      await bloc!.unregisterToken(token);
    }
    return NotificationInitial();
  }
}

class CallbackEvent extends NotificationEvent {
  final Map<String, dynamic> message;
  final CallbackType type;

  const CallbackEvent({required this.message, required this.type});

  @override
  List<Object> get props => [message, type];

  @override
  Future<NotificationState> applyAsync(
      {NotificationState? currentState, NotificationBloc? bloc}) async {
    return NotificationReceived(
      message: this.message,
    );
  }
}

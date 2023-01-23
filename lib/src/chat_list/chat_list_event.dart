import 'dart:async';
import 'dart:developer' as developer;

import 'index.dart';
import 'package:meta/meta.dart';
import '../repository/rice_meteor_service.dart';

@immutable
abstract class ChatListEvent {
  Future<ChatListState> applyAsync(
      {ChatListState? currentState, ChatListBloc? bloc});
}

class UnChatListEvent extends ChatListEvent {
  @override
  Future<ChatListState> applyAsync(
      {ChatListState? currentState, ChatListBloc? bloc}) async {
    if (currentState is InChatListState) {
      if (currentState.chats != null) {
        currentState.chats.unsubscribe();
      }
    }
    return UnChatListState(0);
  }
}

class LoadChatListEvent extends ChatListEvent {
  final bool isError;
  @override
  String toString() => 'LoadChatListEvent';

  LoadChatListEvent(this.isError);

  @override
  Future<ChatListState> applyAsync(
      {ChatListState? currentState, ChatListBloc? bloc}) async {
    try {
      if (currentState is InChatListState) {
        return currentState.getNewVersion();
      }

      ChatListSubscription subscription = bloc!.findChats();
      // subscription.connectionStatus.listen((status) {
      //   if (!status.connected) {
      //     bloc.add(UnChatListEvent());
      //   } else {
      //     bloc.add(LoadChatListEvent(false));
      //   }
      // });
      return InChatListState(0, 'Hello world', subscription);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadChatListEvent', error: _, stackTrace: stackTrace);
      return ErrorChatListState(0, _.toString());
    }
  }
}

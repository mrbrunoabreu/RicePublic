import 'dart:async';
import 'dart:developer' as developer;

import 'index.dart';
import 'package:meta/meta.dart';
import '../repository/model/chat.dart';
import '../repository/model/profile.dart';

@immutable
abstract class ChatRoomEvent {
  final List<Profile?>? profiles;

  ChatRoomEvent(this.profiles);
  Future<ChatRoomState> applyAsync(
      {ChatRoomState? currentState, ChatRoomBloc? bloc});
}

class UnChatRoomEvent extends ChatRoomEvent {
  UnChatRoomEvent(List<Profile?>? profiles) : super(profiles);

  @override
  Future<ChatRoomState> applyAsync(
      {ChatRoomState? currentState, ChatRoomBloc? bloc}) async {
    if (currentState is InChatRoomState) {
      if (currentState.subscription != null) {
        currentState.subscription.unsubscribe();
      }
    }
    return UnChatRoomState(0);
  }
}

class LoadChatRoomEvent extends ChatRoomEvent {
  final bool isError;

  final ChatMetadata? chat;
  @override
  String toString() => 'LoadChatRoomEvent';

  LoadChatRoomEvent(this.isError,
      {required this.chat, required List<Profile?>? profiles})
      : super(profiles);

  @override
  Future<ChatRoomState> applyAsync(
      {ChatRoomState? currentState, ChatRoomBloc? bloc}) async {
    try {
      if (currentState is InChatRoomState) {
        return currentState.getNewVersion();
      }

      final subscription = bloc!.subscribeChatMessages(chatId: this.chat!.id);
      SendMessageMetadata? messageRequest = null;

      final user = await bloc.getUser();

      return InChatRoomState(
        0,
        'Hello world',
        currentUser: user,
        profiles: profiles,
        subscription: subscription,
        messageRequest: messageRequest,
      );
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadChatRoomEvent', error: _, stackTrace: stackTrace);
      return ErrorChatRoomState(0, _.toString());
    }
  }
}

class SendMessageEvent extends ChatRoomEvent {
  final ChatMetadata? chat;
  final String text;

  SendMessageEvent(
      {required this.chat,
      required this.text,
      required List<Profile?>? profiles})
      : super(profiles);

  @override
  Future<ChatRoomState> applyAsync({
    ChatRoomState? currentState,
    ChatRoomBloc? bloc,
  }) async {
    await bloc!.sendMessage(text: this.text, chat: this.chat);
    return InChatRoomState(
      0,
      '',
      subscription: (currentState as InChatRoomState).subscription,
      currentUser: currentState.currentUser,
      profiles: currentState.profiles,
      text: '',
    );
  }
}

class ChangingSendMessageRequestEvent extends ChatRoomEvent {
  ChangingSendMessageRequestEvent(List<Profile> profiles) : super(profiles);

  @override
  Future<ChatRoomState> applyAsync({
    ChatRoomState? currentState,
    ChatRoomBloc? bloc,
  }) async {
    return InChatRoomState(
      0,
      '',
      subscription: (currentState as InChatRoomState).subscription,
      currentUser: currentState.currentUser,
      profiles: currentState.profiles,
      messageRequest: currentState.messageRequest,
      isChangingStatus: true,
    );
  }
}

class ChangeSendMessageRequestEvent extends ChatRoomEvent {
  final ChatMetadata chat;
  final String status;
  final SendMessageMetadata request;

  ChangeSendMessageRequestEvent(
      {required this.chat,
      required this.status,
      required this.request,
      required List<Profile> profiles})
      : super(profiles);

  @override
  Future<ChatRoomState> applyAsync({
    ChatRoomState? currentState,
    ChatRoomBloc? bloc,
  }) async {
    if (this.status == ChatMetadata.STATUS_ACCEPTED) {
      await bloc!.acceptSendMessageRequest(
        request: this.request,
        chat: this.chat,
      );
    } else if (this.status == ChatMetadata.STATUS_DECLINED) {
      await bloc!.declineSendMessageRequest(
        request: this.request,
        chat: this.chat,
      );
    } else if (this.status == ChatMetadata.STATUS_IGNORED) {
      await bloc!.ignoreSendMessageRequest(
        request: this.request,
        chat: this.chat,
      );
    }

    final prevState = currentState as InChatRoomState;

    return InChatRoomState(
      0,
      'ChangeSendMessageRequestEvent',
      subscription: prevState.subscription,
      currentUser: prevState.currentUser,
      profiles: profiles,
      messageRequest: null,
      isChangingStatus: false,
    );
  }
}

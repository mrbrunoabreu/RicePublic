import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../repository/model/chat.dart';
import '../repository/model/profile.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import '../repository/rice_meteor_service.dart';
import '../repository/rice_repository.dart';

class ChatRoomBloc extends BaseBloc<ChatRoomEvent, ChatRoomState> {
  ChatRoomBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnChatRoomState(0));

  ChatMessagesSubscription? _subscription;

  Future<List<Profile>> findProfiles(List<String> users) {
    return this.riceRepository.findProfiles(users: users);
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  Future<User> getUser() {
    return this.riceRepository.getCurrentUser();
  }

  Future<void> acceptSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) {
    return this.riceRepository.acceptSendMessageRequest(
          request: request,
          chat: chat,
        );
  }

  Future<void> declineSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) {
    return this.riceRepository.declineSendMessageRequest(
          request: request,
          chat: chat,
        );
  }

  Future<void> ignoreSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) {
    return this.riceRepository.ignoreSendMessageRequest(
          request: request,
          chat: chat,
        );
  }

  Future<List<ChatMessage>> findChatMessages({required String chatId}) {
    if (_subscription != null) {
      // _subscription.messages()
    }

    return this.riceRepository.findChatMessages(chatId: chatId);
  }

  Future<Restaurant?> findRestaurant({required String? restaurantId}) {
    return this.riceRepository.findRestaurant(restaurantId);
  }

  ChatMessagesSubscription subscribeChatMessages({required String? chatId}) {
    ChatMessagesSubscription subscription =
        riceRepository.subscribeChatMessages(chatId: chatId, limit: 50);
    return subscription;
  }

  unsubscribeChatMessages() {
    if (_subscription != null) {
      _subscription!.unsubscribe();
      _subscription = null;
    }
  }

  Future<void> sendMessage({
    required String text,
    required ChatMetadata? chat,
  }) {
    return this.riceRepository.sendMessage(text: text, chat: chat);
  }

  @override
  Future<void> mapEventToState(
    ChatRoomEvent event,
    Emitter<ChatRoomState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ChatRoomBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

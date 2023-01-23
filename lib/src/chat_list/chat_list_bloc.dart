import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/model/profile.dart';
import '../repository/rice_meteor_service.dart';
import '../repository/rice_repository.dart';

import '../base_bloc.dart';

import '../repository/model/chat.dart';

class ChatListBloc extends BaseBloc<ChatListEvent, ChatListState> {
  ChatListBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnChatListState(0));

  Future<List<Profile>> findProfiles(List<String> users) {
    return this.riceRepository.findProfiles(users: users);
  }

  Stream<List<RawMessageData>> findLastMessage({String? chatId}) {
    return this.riceRepository.findLastMessageByChatId(chatId: chatId);
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  ChatListSubscription findChats() {
    return this.riceRepository.findChats();
  }

  @override
  Future<void> mapEventToState(
    ChatListEvent event,
    Emitter<ChatListState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ChatListBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

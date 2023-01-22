import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import 'package:rice/src/find_chat_partner/find_chat_partner_event.dart';
import 'package:rice/src/find_chat_partner/find_chat_partner_state.dart';
import '../repository/model/chat.dart';
import '../repository/model/restaurant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:developer' as developer;

import '../repository/model/user.dart';
import '../repository/rice_repository.dart';
import 'package:rxdart/rxdart.dart';

class FindChatPartnerBloc
    extends BaseBloc<FindChatPartnerEvent, FindChatPartnerState> {
  FindChatPartnerBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnFindChatPartnerState(0)) {
    on<FindChatPartnerEvent>(mapEventToState, transformer: debounce());
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  Future<void> addUserToChatGroup({
    required String? user,
    required String? group,
  }) {
    return this.riceRepository.addUserToChatGroup(user: user, group: group);
  }

  Future<User> getUser() {
    return this.riceRepository.getCurrentUser();
  }

  Future<List<ChatPartner>> findChatPartners({required String name}) {
    return this.riceRepository.findChatPartners(name: name);
  }

  Future<ChatMetadata> startChat({required User? user}) {
    return this.riceRepository.startChat(user: user);
  }

  Future<void> shareRestaurant(
      {required String? chat, required Restaurant restaurant}) {
    return this.riceRepository.sendRestaurant(
          chat: chat,
          restaurant: restaurant,
        );
  }

  Future<ChatMetadata> createChatGroup({List<User?>? users}) {
    return this.riceRepository.createChatGroup(users: users);
  }

  EventTransformer<FindChatPartnerEvent> debounce<FindChatPartnerEvent>(
      {Duration duration = const Duration(milliseconds: 500)}) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  @override
  Future<void> mapEventToState(
    FindChatPartnerEvent event,
    Emitter<FindChatPartnerState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'FindChatPartnerBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}

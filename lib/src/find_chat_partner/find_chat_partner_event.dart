import 'package:flutter/foundation.dart';
import 'find_chat_partner_bloc.dart';
import 'find_chat_partner_state.dart';
import '../repository/model/chat.dart';
import '../repository/model/user.dart';
import 'package:rxdart/transformers.dart';

@immutable
abstract class FindChatPartnerEvent {
  Future<FindChatPartnerState> applyAsync(
      {FindChatPartnerState? currentState, FindChatPartnerBloc? bloc});
}

class UnFindChatPartnerEvent extends FindChatPartnerEvent {
  @override
  Future<FindChatPartnerState> applyAsync(
      {FindChatPartnerState? currentState, FindChatPartnerBloc? bloc}) async {
    return UnFindChatPartnerState(0);
  }
}

class SearchByNameEvent extends FindChatPartnerEvent {
  final String name;

  SearchByNameEvent({
    required this.name,
  }) {}

  @override
  Future<FindChatPartnerState> applyAsync(
      {FindChatPartnerState? currentState, FindChatPartnerBloc? bloc}) async {
    final partners = await bloc!.findChatPartners(name: this.name);

    return Future.value(
      InFindChatPartnerState(
        0,
        '',
        partners: partners,
        currentUser: (currentState as InFindChatPartnerState).currentUser,
      ),
    );
  }
}

class LoadFindChatPartnerEvent extends FindChatPartnerEvent {
  @override
  Future<FindChatPartnerState> applyAsync(
      {FindChatPartnerState? currentState, FindChatPartnerBloc? bloc}) async {
    final currentUser = await bloc!.getUser();

    return InFindChatPartnerState(
      0,
      '',
      partners: [],
      currentUser: currentUser,
    );
  }
}

class CreateChatGroupEvent extends FindChatPartnerEvent {
  final List<User?> users;

  CreateChatGroupEvent({
    required this.users,
  }) {}

  @override
  Future<FindChatPartnerState> applyAsync({
    FindChatPartnerState? currentState,
    FindChatPartnerBloc? bloc,
  }) async {
    final chat = await bloc!.createChatGroup(users: this.users);

    return CreatedChatGroupState(1, chat: chat);
  }
}

class AddUsersToChatGroupEvent extends FindChatPartnerEvent {
  final String? group;
  final List<String?> users;

  AddUsersToChatGroupEvent({
    required this.group,
    required this.users,
  }) {}

  @override
  Future<FindChatPartnerState> applyAsync({
    FindChatPartnerState? currentState,
    FindChatPartnerBloc? bloc,
  }) async {
    for (String? user in this.users) {
      await bloc!.addUserToChatGroup(user: user, group: this.group);
    }

    return AddedUsersToChatGroupState(1);
  }
}

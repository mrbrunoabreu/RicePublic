import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import '../repository/model/chat.dart';
import '../repository/model/user.dart';

abstract class FindChatPartnerState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  FindChatPartnerState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  FindChatPartnerState getStateCopy();

  FindChatPartnerState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

class UnFindChatPartnerState extends FindChatPartnerState with NeedShowLoader {
  UnFindChatPartnerState(int version) : super(version);

  @override
  String toString() => 'UnFindChatPartnerState';

  @override
  UnFindChatPartnerState getStateCopy() {
    return UnFindChatPartnerState(0);
  }

  @override
  UnFindChatPartnerState getNewVersion() {
    return UnFindChatPartnerState(version + 1);
  }
}

class InFindChatPartnerState extends FindChatPartnerState {
  final String hello;
  final List<ChatPartner> partners;
  final User currentUser;

  InFindChatPartnerState(int version, this.hello,
      {required this.partners, required this.currentUser})
      : super(version, [hello, partners]);

  @override
  String toString() => 'InFindChatPartnerState $hello';

  @override
  InFindChatPartnerState getStateCopy() {
    return InFindChatPartnerState(
      this.version,
      this.hello,
      partners: this.partners,
      currentUser: this.currentUser,
    );
  }

  @override
  InFindChatPartnerState getNewVersion() {
    return InFindChatPartnerState(
      version + 1,
      this.hello,
      partners: this.partners,
      currentUser: this.currentUser,
    );
  }
}

class CreatedChatGroupState extends FindChatPartnerState {
  final ChatMetadata chat;

  CreatedChatGroupState(int version, {required this.chat})
      : super(version, [chat]);

  @override
  String toString() => 'CreatedChatGroupState';

  @override
  CreatedChatGroupState getStateCopy() {
    return CreatedChatGroupState(
      this.version,
      chat: this.chat,
    );
  }

  @override
  CreatedChatGroupState getNewVersion() {
    return CreatedChatGroupState(version + 1, chat: this.chat);
  }
}

class AddedUsersToChatGroupState extends FindChatPartnerState {
  AddedUsersToChatGroupState(int version) : super(version, []);

  @override
  String toString() => 'AddedUsersToChatGroupState';

  @override
  AddedUsersToChatGroupState getStateCopy() {
    return AddedUsersToChatGroupState(
      this.version,
    );
  }

  @override
  AddedUsersToChatGroupState getNewVersion() {
    return AddedUsersToChatGroupState(version + 1);
  }
}

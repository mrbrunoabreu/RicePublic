import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../base_bloc.dart';
import '../repository/model/chat.dart';
import '../repository/model/profile.dart';
import '../repository/model/user.dart';
import '../repository/rice_meteor_service.dart';

abstract class ChatRoomState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ChatRoomState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ChatRoomState getStateCopy();

  ChatRoomState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnChatRoomState extends ChatRoomState with NeedShowLoader {
  UnChatRoomState(int version) : super(version);

  @override
  String toString() => 'UnChatRoomState';

  @override
  UnChatRoomState getStateCopy() {
    return UnChatRoomState(0);
  }

  @override
  UnChatRoomState getNewVersion() {
    return UnChatRoomState(version + 1);
  }
}

/// Initialized
class InChatRoomState extends ChatRoomState {
  final String hello;

  final ChatMessagesSubscription subscription;
  final SendMessageMetadata? messageRequest;
  final User currentUser;
  final List<Profile?>? profiles;
  final String? text;
  final bool isChangingStatus;

  InChatRoomState(
    int version,
    this.hello, {
    required this.subscription,
    required this.currentUser,
    required this.profiles,
    this.messageRequest = null,
    this.text = null,
    this.isChangingStatus = false,
  }) : super(version, [hello]);

  @override
  String toString() => 'InChatRoomState $hello';

  @override
  InChatRoomState getStateCopy() {
    return InChatRoomState(
      this.version,
      this.hello,
      currentUser: this.currentUser,
      profiles: this.profiles,
      subscription: this.subscription,
      messageRequest: this.messageRequest,
      isChangingStatus: this.isChangingStatus,
      text: this.text,
    );
  }

  @override
  InChatRoomState getNewVersion() {
    return InChatRoomState(
      version + 1,
      this.hello,
      currentUser: this.currentUser,
      profiles: this.profiles,
      subscription: this.subscription,
      messageRequest: this.messageRequest,
      isChangingStatus: this.isChangingStatus,
      text: this.text,
    );
  }
}

class ErrorChatRoomState extends ChatRoomState {
  final String errorMessage;

  ErrorChatRoomState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorChatRoomState';

  @override
  ErrorChatRoomState getStateCopy() {
    return ErrorChatRoomState(this.version, this.errorMessage);
  }

  @override
  ErrorChatRoomState getNewVersion() {
    return ErrorChatRoomState(version + 1, this.errorMessage);
  }
}

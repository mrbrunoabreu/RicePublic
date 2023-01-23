import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/rice_meteor_service.dart';

abstract class ChatListState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ChatListState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ChatListState getStateCopy();

  ChatListState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnChatListState extends ChatListState with NeedShowLoader {
  UnChatListState(int version) : super(version);

  @override
  String toString() => 'UnChatListState';

  @override
  UnChatListState getStateCopy() {
    return UnChatListState(0);
  }

  @override
  UnChatListState getNewVersion() {
    return UnChatListState(version + 1);
  }
}

/// Initialized
class InChatListState extends ChatListState {
  final String hello;
  final ChatListSubscription chats;

  InChatListState(int version, this.hello, this.chats)
      : super(version, [hello, chats]);

  @override
  String toString() => 'InChatListState $hello';

  @override
  InChatListState getStateCopy() {
    return InChatListState(this.version, this.hello, this.chats);
  }

  @override
  InChatListState getNewVersion() {
    return InChatListState(version + 1, this.hello, this.chats);
  }
}

class ErrorChatListState extends ChatListState {
  final String errorMessage;

  ErrorChatListState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorChatListState';

  @override
  ErrorChatListState getStateCopy() {
    return ErrorChatListState(this.version, this.errorMessage);
  }

  @override
  ErrorChatListState getNewVersion() {
    return ErrorChatListState(version + 1, this.errorMessage);
  }
}

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../model/plan.dart';
import '../model/profile.dart';
import '../model/user.dart';
import '../rice_meteor_service.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatMetadata {
  static final String STATUS_ACCEPTED = 'accepted';
  static final String STATUS_IGNORED = 'ignored';
  static final String STATUS_DECLINED = 'declined';

  final String? id;

  String? name;
  final String? planId;
  final List<String?>? members;
  @JsonKey(ignore: true)
  RawMessageData? lastMessage;
  @JsonKey(ignore: true)
  Map<String?, User?>? users;

  ChatMetadata({
    this.id,
    this.name,
    this.members,
    this.planId,
    this.lastMessage,
  });

  factory ChatMetadata.fromJson(Map<String, dynamic> json) =>
      _$ChatMetadataFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ChatMetadataToJson(this);

    return json;
  }
}

@JsonSerializable()
class ChatMessage {
  static String TYPE_TEXT = 'text';
  static String TYPE_LOCATION = 'location';

  final String? id;
  final String? message;
  final DateTime? createdAt;
  final String? type;

  final String? senderId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.createdAt,
    this.type,
    this.senderId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ChatMessageToJson(this);

    return json;
  }
}

@JsonSerializable()
class ChatRoom {
  final List<ChatMessage>? messages;

  ChatRoom({required this.messages});

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ChatRoomToJson(this);

    return json;
  }
}

@JsonSerializable()
class ChatPartner {
  final User? user;
  final ChatMetadata? chat;

  ChatPartner({required this.user, required this.chat}) {}

  factory ChatPartner.fromJson(Map<String, dynamic> json) =>
      _$ChatPartnerFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ChatPartnerToJson(this);

    return json;
  }
}

@JsonSerializable()
class SendMessageMetadata {
  final User? createdBy;
  final DateTime? createdAt;
  final String? description;

  SendMessageMetadata({
    required this.createdBy,
    required this.createdAt,
    required this.description,
  });

  factory SendMessageMetadata.fromJson(Map<String, dynamic> json) =>
      _$SendMessageMetadataFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$SendMessageMetadataToJson(this);

    return json;
  }
}

// {"msg":"added","collection":"messages","id":"Zkj93sNfuQWAwuqhx","fields":{"chatId":"3Y6dKQen8v7g4uqEJ","senderId":"97kKnT3rdMYvHgqpB","content":"test","createdAt":{"$date":1593338586786},"type":"text"}}
@JsonSerializable()
class RawMessageData {
  @JsonKey(name: '_id')
  String? id;
  final String? chatId;
  final String? senderId;
  final String? content;
  final String? type;

  // TODO: use final
  @JsonKey(ignore: true)
  DateTime createdAt;

  RawMessageData({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.type,
  });

  factory RawMessageData.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      DateTime createdAt =
          DateTime.fromMillisecondsSinceEpoch(json['createdAt']['\$date']);
      RawMessageData data = _$RawMessageDataFromJson(json);
      data.id = json['_id'];
      data.createdAt = createdAt;
      return data;
    }
    throw ArgumentError("RawMessage json is null");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$RawMessageDataToJson(this);

    return json;
  }
}

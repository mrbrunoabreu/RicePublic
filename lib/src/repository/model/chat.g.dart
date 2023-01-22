// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMetadata _$ChatMetadataFromJson(Map<String, dynamic> json) {
  return ChatMetadata(
    id: json['id'] as String?,
    name: json['name'] as String?,
    members: (json['members'] as List?)?.map((e) => e as String)?.toList(),
    planId: json['planId'] as String?,
  );
}

Map<String, dynamic> _$ChatMetadataToJson(ChatMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'planId': instance.planId,
      'members': instance.members,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return ChatMessage(
    id: json['id'] as String?,
    message: json['message'] as String?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    type: json['type'] as String?,
    senderId: json['senderId'] as String?,
  );
}

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'createdAt': instance.createdAt?.toIso8601String(),
      'type': instance.type,
      'senderId': instance.senderId,
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) {
  return ChatRoom(
    messages: (json['messages'] as List?)
        ?.map((e) =>
            ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
      'messages': instance.messages,
    };

ChatPartner _$ChatPartnerFromJson(Map<String, dynamic> json) {
  return ChatPartner(
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    chat: json['chat'] == null
        ? null
        : ChatMetadata.fromJson(json['chat'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ChatPartnerToJson(ChatPartner instance) =>
    <String, dynamic>{
      'user': instance.user,
      'chat': instance.chat,
    };

SendMessageMetadata _$SendMessageMetadataFromJson(Map<String, dynamic> json) {
  return SendMessageMetadata(
    createdBy: json['createdBy'] == null
        ? null
        : User.fromJson(json['createdBy'] as Map<String, dynamic>),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    description: json['description'] as String?,
  );
}

Map<String, dynamic> _$SendMessageMetadataToJson(
        SendMessageMetadata instance) =>
    <String, dynamic>{
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'description': instance.description,
    };

RawMessageData _$RawMessageDataFromJson(Map<String, dynamic> json) {
  return RawMessageData(
    id: json['_id'] as String?,
    chatId: json['chatId'] as String?,
    senderId: json['senderId'] as String?,
    content: json['content'] as String?,
    type: json['type'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

Map<String, dynamic> _$RawMessageDataToJson(RawMessageData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'content': instance.content,
      'type': instance.type,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$ChatMetadataToString(ChatMetadata o) {
  return """ChatMetadata{id: ${o.id}, name: ${o.name}, planId: ${o.planId}, members: ${o.members}, lastMessage: ${o.lastMessage}, users: ${o.users}}""";
}

String _$ChatMessageToString(ChatMessage o) {
  return """ChatMessage{id: ${o.id}, message: ${o.message}, createdAt: ${o.createdAt}, type: ${o.type}, senderId: ${o.senderId}}""";
}

String _$ChatRoomToString(ChatRoom o) {
  return """ChatRoom{messages: ${o.messages}}""";
}

String _$ChatPartnerToString(ChatPartner o) {
  return """ChatPartner{user: ${o.user}, chat: ${o.chat}}""";
}

String _$SendMessageMetadataToString(SendMessageMetadata o) {
  return """SendMessageMetadata{createdBy: ${o.createdBy}, createdAt: ${o.createdAt}, description: ${o.description}}""";
}

String _$RawMessageDataToString(RawMessageData o) {
  return """RawMessageData{id: ${o.id}, chatId: ${o.chatId}, senderId: ${o.senderId}, content: ${o.content}, type: ${o.type}, createdAt: ${o.createdAt}}""";
}

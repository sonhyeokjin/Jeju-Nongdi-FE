// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomResponse _$ChatRoomResponseFromJson(Map<String, dynamic> json) =>
    ChatRoomResponse(
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String,
      otherUser: json['otherUser'] == null
          ? null
          : UserResponse.fromJson(json['otherUser'] as Map<String, dynamic>),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] == null
          ? null
          : DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$ChatRoomResponseToJson(ChatRoomResponse instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'otherUser': instance.otherUser,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': instance.lastMessageTime?.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };

ChatMessageResponse _$ChatMessageResponseFromJson(Map<String, dynamic> json) =>
    ChatMessageResponse(
      messageId: json['messageId'] as String,
      roomId: json['roomId'] as String,
      sender: UserResponse.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      fileUrl: json['fileUrl'] as String?,
      messageType: json['messageType'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$ChatMessageResponseToJson(
  ChatMessageResponse instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'roomId': instance.roomId,
  'sender': instance.sender,
  'content': instance.content,
  'fileUrl': instance.fileUrl,
  'messageType': instance.messageType,
  'sentAt': instance.sentAt.toIso8601String(),
};

ChatMessageRequest _$ChatMessageRequestFromJson(Map<String, dynamic> json) =>
    ChatMessageRequest(content: json['content'] as String);

Map<String, dynamic> _$ChatMessageRequestToJson(ChatMessageRequest instance) =>
    <String, dynamic>{'content': instance.content};

ChatRoomCreateRequest _$ChatRoomCreateRequestFromJson(
  Map<String, dynamic> json,
) => ChatRoomCreateRequest(otherUserId: (json['otherUserId'] as num).toInt());

Map<String, dynamic> _$ChatRoomCreateRequestToJson(
  ChatRoomCreateRequest instance,
) => <String, dynamic>{'otherUserId': instance.otherUserId};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomResponse _$ChatRoomResponseFromJson(Map<String, dynamic> json) =>
    ChatRoomResponse(
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String?,
      otherUser: json['otherUser'] == null
          ? null
          : UserResponse.fromJson(json['otherUser'] as Map<String, dynamic>),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] == null
          ? null
          : DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
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
) => ChatRoomCreateRequest(
  chatType: json['chatType'] as String,
  participantId: (json['participantId'] as num).toInt(),
  referenceId: (json['referenceId'] as num).toInt(),
  initialMessage: json['initialMessage'] as String?,
);

Map<String, dynamic> _$ChatRoomCreateRequestToJson(
  ChatRoomCreateRequest instance,
) => <String, dynamic>{
  'chatType': instance.chatType,
  'participantId': instance.participantId,
  'referenceId': instance.referenceId,
  'initialMessage': instance.initialMessage,
};

UnreadCountResponse _$UnreadCountResponseFromJson(Map<String, dynamic> json) =>
    UnreadCountResponse(unreadCount: (json['unreadCount'] as num).toInt());

Map<String, dynamic> _$UnreadCountResponseToJson(
  UnreadCountResponse instance,
) => <String, dynamic>{'unreadCount': instance.unreadCount};

WebSocketConnectionInfo _$WebSocketConnectionInfoFromJson(
  Map<String, dynamic> json,
) => WebSocketConnectionInfo(
  endpoint: json['endpoint'] as String,
  protocol: json['protocol'] as String,
  authentication: json['authentication'] as String?,
  sendDestination: json['sendDestination'] as String?,
  subscribePattern: json['subscribePattern'] as String?,
  sockJsEnabled: json['sockJsEnabled'] as bool?,
);

Map<String, dynamic> _$WebSocketConnectionInfoToJson(
  WebSocketConnectionInfo instance,
) => <String, dynamic>{
  'endpoint': instance.endpoint,
  'protocol': instance.protocol,
  'authentication': instance.authentication,
  'sendDestination': instance.sendDestination,
  'subscribePattern': instance.subscribePattern,
  'sockJsEnabled': instance.sockJsEnabled,
};

OneToOneChatRoomDto _$OneToOneChatRoomDtoFromJson(Map<String, dynamic> json) =>
    OneToOneChatRoomDto(
      roomId: json['roomId'] as String,
      user1Id: (json['user1Id'] as num).toInt(),
      user2Id: (json['user2Id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      otherUserNickname: json['otherUserNickname'] as String,
      otherUserProfileImage: json['otherUserProfileImage'] as String?,
    );

Map<String, dynamic> _$OneToOneChatRoomDtoToJson(
  OneToOneChatRoomDto instance,
) => <String, dynamic>{
  'roomId': instance.roomId,
  'user1Id': instance.user1Id,
  'user2Id': instance.user2Id,
  'createdAt': instance.createdAt.toIso8601String(),
  'otherUserNickname': instance.otherUserNickname,
  'otherUserProfileImage': instance.otherUserProfileImage,
};

ChatRoomDto _$ChatRoomDtoFromJson(Map<String, dynamic> json) => ChatRoomDto(
  roomId: json['roomId'] as String,
  roomName: json['roomName'] as String?,
  chatType: json['chatType'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastMessage: json['lastMessage'] as String?,
  lastMessageTime: json['lastMessageTime'] == null
      ? null
      : DateTime.parse(json['lastMessageTime'] as String),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChatRoomDtoToJson(ChatRoomDto instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'chatType': instance.chatType,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': instance.lastMessageTime?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ChatRoomView _$ChatRoomViewFromJson(Map<String, dynamic> json) => ChatRoomView(
  roomId: json['roomId'] as String,
  roomName: json['roomName'] as String?,
  otherUser: json['otherUser'] == null
      ? null
      : UserResponse.fromJson(json['otherUser'] as Map<String, dynamic>),
  lastMessage: json['lastMessage'] as String?,
  lastMessageTime: json['lastMessageTime'] == null
      ? null
      : DateTime.parse(json['lastMessageTime'] as String),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  chatType: json['chatType'] as String? ?? 'GENERAL',
);

Map<String, dynamic> _$ChatRoomViewToJson(ChatRoomView instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'otherUser': instance.otherUser,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': instance.lastMessageTime?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'chatType': instance.chatType,
    };

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  messageId: json['messageId'] as String,
  roomId: json['roomId'] as String,
  sender: UserResponse.fromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String,
  fileUrl: json['fileUrl'] as String?,
  messageType: json['messageType'] as String,
  sentAt: DateTime.parse(json['sentAt'] as String),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'roomId': instance.roomId,
      'sender': instance.sender,
      'content': instance.content,
      'fileUrl': instance.fileUrl,
      'messageType': instance.messageType,
      'sentAt': instance.sentAt.toIso8601String(),
      'isRead': instance.isRead,
    };

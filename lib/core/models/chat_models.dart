import 'package:json_annotation/json_annotation.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // UserResponse 재사용

part 'chat_models.g.dart';

// 채팅방 목록의 각 아이템
@JsonSerializable()
class ChatRoomResponse {
  final String roomId;
  final String roomName;
  final UserResponse? otherUser; // 1:1 채팅의 경우 상대방 정보
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatRoomResponse({
    required this.roomId,
    required this.roomName,
    this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomResponseToJson(this);
}


// 채팅 메시지 모델
@JsonSerializable()
class ChatMessageResponse {
  final String messageId;
  final String roomId;
  final UserResponse sender;
  final String content;
  final String? fileUrl; // 파일 메시지인 경우
  final String messageType; // TEXT, FILE 등
  final DateTime sentAt;

  ChatMessageResponse({
    required this.messageId,
    required this.roomId,
    required this.sender,
    required this.content,
    this.fileUrl,
    required this.messageType,
    required this.sentAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageResponseToJson(this);
}

// 메시지 전송 요청 모델
@JsonSerializable()
class ChatMessageRequest {
  final String content;
  // roomId는 경로 파라미터로 전송되므로 여기서는 제외

  ChatMessageRequest({required this.content});

  factory ChatMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageRequestToJson(this);
}

// 채팅방 생성 요청 모델
@JsonSerializable()
class ChatRoomCreateRequest {
  // 예시: 1:1 채팅 생성을 위해 상대방 사용자 ID를 포함
  final int otherUserId;

  ChatRoomCreateRequest({required this.otherUserId});

  factory ChatRoomCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomCreateRequestToJson(this);
}
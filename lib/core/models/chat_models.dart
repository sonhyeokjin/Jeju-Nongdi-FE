import 'package:json_annotation/json_annotation.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // UserResponse 재사용

part 'chat_models.g.dart';

// 채팅 타입 열거형
enum ChatType {
  @JsonValue('MENTORING')
  mentoring,
  @JsonValue('FARMLAND')
  farmland,
  @JsonValue('JOB_POSTING')
  jobPosting,
  @JsonValue('GENERAL')
  general,
}

// 메시지 타입 열거형
enum MessageType {
  @JsonValue('TEXT')
  text,
  @JsonValue('FILE')
  file,
}

// 채팅방 목록의 각 아이템
@JsonSerializable()
class ChatRoomResponse {
  final String roomId;
  final String? roomName;
  final UserResponse? otherUser; // 1:1 채팅의 경우 상대방 정보
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatRoomResponse({
    required this.roomId,
    this.roomName,
    this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0, // 기본값 설정
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
  final String chatType; // MENTORING, FARMLAND, JOB_POSTING, GENERAL
  final int participantId; // 상대방 사용자 ID
  final int referenceId; // 관련 게시물/농지 등의 ID
  final String? initialMessage; // 초기 메시지 (선택)

  ChatRoomCreateRequest({
    required this.chatType,
    required this.participantId,
    required this.referenceId,
    this.initialMessage,
  });

  factory ChatRoomCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomCreateRequestToJson(this);
}

// 읽지 않은 메시지 개수 응답 모델
@JsonSerializable()
class UnreadCountResponse {
  final int unreadCount;

  UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}
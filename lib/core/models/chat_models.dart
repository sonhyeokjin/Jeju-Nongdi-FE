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

// WebSocket 연결 정보 모델
@JsonSerializable()
class WebSocketConnectionInfo {
  final String endpoint;
  final String protocol;
  final String? authentication;
  final String? sendDestination;
  final String? subscribePattern;
  final bool? sockJsEnabled;

  WebSocketConnectionInfo({
    required this.endpoint,
    required this.protocol,
    this.authentication,
    this.sendDestination,
    this.subscribePattern,
    this.sockJsEnabled,
  });

  factory WebSocketConnectionInfo.fromJson(Map<String, dynamic> json) =>
      _$WebSocketConnectionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WebSocketConnectionInfoToJson(this);
}

// 1:1 채팅방 조회/생성 API 응답 모델 
@JsonSerializable()
class OneToOneChatRoomDto {
  final String roomId;
  final int user1Id;
  final int user2Id;
  final DateTime createdAt;
  final String otherUserNickname;
  final String? otherUserProfileImage;

  OneToOneChatRoomDto({
    required this.roomId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.otherUserNickname,
    this.otherUserProfileImage,
  });

  factory OneToOneChatRoomDto.fromJson(Map<String, dynamic> json) =>
      _$OneToOneChatRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OneToOneChatRoomDtoToJson(this);
}

// 채팅방 상세 정보 (API 명세의 ChatRoomDto)
@JsonSerializable()
class ChatRoomDto {
  final String roomId;
  final String? roomName;
  final String chatType;
  final List<UserResponse> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatRoomDto({
    required this.roomId,
    this.roomName,
    required this.chatType,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomDtoToJson(this);
}

// 채팅방 뷰 모델 (API 명세의 ChatRoomView)
class ChatRoomView {
  final String roomId;
  final String? roomName;
  final UserResponse? otherUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String chatType;

  ChatRoomView({
    required this.roomId,
    this.roomName,
    this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.chatType = 'GENERAL', // 기본값 제공
  });

  factory ChatRoomView.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 ChatRoomView 파싱 중: $json');
      
      // roomId 검증
      final roomId = json['roomId'] as String?;
      if (roomId == null || roomId.isEmpty) {
        throw Exception('roomId가 null이거나 비어있습니다');
      }
      
      // otherUser 파싱
      UserResponse? otherUser;
      if (json['otherUser'] != null) {
        try {
          if (json['otherUser'] is Map<String, dynamic>) {
            otherUser = UserResponse.fromJson(json['otherUser'] as Map<String, dynamic>);
          }
        } catch (e) {
          print('⚠️ otherUser 파싱 실패: $e');
          otherUser = null;
        }
      }
      
      // lastMessageTime 파싱
      DateTime? lastMessageTime;
      if (json['lastMessageTime'] != null) {
        try {
          if (json['lastMessageTime'] is String) {
            lastMessageTime = DateTime.parse(json['lastMessageTime'] as String);
          }
        } catch (e) {
          print('⚠️ lastMessageTime 파싱 실패: $e');
          lastMessageTime = null;
        }
      }
      
      final result = ChatRoomView(
        roomId: roomId,
        roomName: json['roomName'] as String?,
        otherUser: otherUser,
        lastMessage: json['lastMessage'] as String?,
        lastMessageTime: lastMessageTime,
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        chatType: json['chatType'] as String? ?? 'GENERAL',
      );
      
      print('✅ ChatRoomView 파싱 성공: roomId=$roomId, chatType=${result.chatType}');
      return result;
    } catch (e) {
      print('❌ ChatRoomView 파싱 오류: $e');
      print('📊 원본 데이터: $json');
      rethrow;
    }
  }
  
  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'roomName': roomName,
    'otherUser': otherUser?.toJson(),
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'unreadCount': unreadCount,
    'chatType': chatType,
  };
}

// 메시지 DTO (API 명세의 MessageDto)
@JsonSerializable()
class MessageDto {
  final String messageId;
  final String roomId;
  final UserResponse sender;
  final String content;
  final String? fileUrl;
  final String messageType;
  final DateTime sentAt;
  final bool isRead;

  MessageDto({
    required this.messageId,
    required this.roomId,
    required this.sender,
    required this.content,
    this.fileUrl,
    required this.messageType,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
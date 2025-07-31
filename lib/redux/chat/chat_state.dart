// lib/redux/chat/chat_state.dart

import 'package:jejunongdi/core/models/chat_models.dart';

class ChatState {
  final bool isLoading;
  final String? error;

  // WebSocket 연결 정보
  final WebSocketConnectionInfo? webSocketInfo;

  // 전체 채팅방 목록
  final List<ChatRoomView> chatRooms;

  // 현재 보고 있는 채팅방의 메시지 목록
  // Map<roomId, List<MessageDto>> 형태로 저장하여 여러 채팅방의 메시지를 관리
  final Map<String, List<MessageDto>> messages;
  final Map<String, bool> hasMoreMessages; // 각 채팅방별 페이징 정보
  final Map<String, int> currentPage; // 각 채팅방별 현재 페이지

  // 1:1 채팅방 정보
  final Map<String, ChatRoomDto> oneToOneRooms; // key: targetEmail

  const ChatState({
    required this.isLoading,
    this.error,
    this.webSocketInfo,
    required this.chatRooms,
    required this.messages,
    required this.hasMoreMessages,
    required this.currentPage,
    required this.oneToOneRooms,
  });

  // 초기 상태
  factory ChatState.initial() {
    return const ChatState(
      isLoading: false,
      error: null,
      webSocketInfo: null,
      chatRooms: [],
      messages: {},
      hasMoreMessages: {},
      currentPage: {},
      oneToOneRooms: {},
    );
  }

  // 상태 복사 및 수정을 위한 copyWith 메서드
  ChatState copyWith({
    bool? isLoading,
    String? error,
    WebSocketConnectionInfo? webSocketInfo,
    List<ChatRoomView>? chatRooms,
    Map<String, List<MessageDto>>? messages,
    Map<String, bool>? hasMoreMessages,
    Map<String, int>? currentPage,
    Map<String, ChatRoomDto>? oneToOneRooms,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // error는 명시적으로 null로 설정 가능해야 하므로 ?? this.error 사용 안함
      webSocketInfo: webSocketInfo ?? this.webSocketInfo,
      chatRooms: chatRooms ?? this.chatRooms,
      messages: messages ?? this.messages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      currentPage: currentPage ?? this.currentPage,
      oneToOneRooms: oneToOneRooms ?? this.oneToOneRooms,
    );
  }
}
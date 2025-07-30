// lib/redux/chat/chat_state.dart

import 'package:jejunongdi/core/models/chat_models.dart';

class ChatState {
  final bool isLoading;
  final String? error;

  // 전체 채팅방 목록
  final List<ChatRoomResponse> chatRooms;

  // 현재 보고 있는 채팅방의 메시지 목록
  // Map<roomId, List<ChatMessage>> 형태로 저장하여 여러 채팅방의 메시지를 관리
  final Map<String, List<ChatMessageResponse>> messages;
  final Map<String, bool> hasMoreMessages; // 각 채팅방별 페이징 정보
  final Map<String, int> currentPage; // 각 채팅방별 현재 페이지

  // 읽지 않은 메시지 총 개수
  final int totalUnreadCount;

  const ChatState({
    required this.isLoading,
    this.error,
    required this.chatRooms,
    required this.messages,
    required this.hasMoreMessages,
    required this.currentPage,
    required this.totalUnreadCount,
  });

  // 초기 상태
  factory ChatState.initial() {
    return const ChatState(
      isLoading: false,
      error: null,
      chatRooms: [],
      messages: {},
      hasMoreMessages: {},
      currentPage: {},
      totalUnreadCount: 0,
    );
  }

  // 상태 복사 및 수정을 위한 copyWith 메서드
  ChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatRoomResponse>? chatRooms,
    Map<String, List<ChatMessageResponse>>? messages,
    Map<String, bool>? hasMoreMessages,
    Map<String, int>? currentPage,
    int? totalUnreadCount,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // error는 명시적으로 null로 설정 가능해야 하므로 ?? this.error 사용 안함
      chatRooms: chatRooms ?? this.chatRooms,
      messages: messages ?? this.messages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      currentPage: currentPage ?? this.currentPage,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
    );
  }
}
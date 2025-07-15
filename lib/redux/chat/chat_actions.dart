// lib/redux/chat/chat_actions.dart

import 'package:jejunongdi/core/models/chat_models.dart';

// --- 공통 액션 ---
class SetChatLoadingAction {
  final bool isLoading;
  SetChatLoadingAction(this.isLoading);
}

class SetChatErrorAction {
  final String error;
  SetChatErrorAction(this.error);
}

// --- 채팅방 목록 관련 액션 ---
class LoadChatRoomsAction {}

class LoadChatRoomsSuccessAction {
  final List<ChatRoomResponse> chatRooms;
  LoadChatRoomsSuccessAction(this.chatRooms);
}

// --- 채팅 메시지 관련 액션 ---
class LoadChatMessagesAction {
  final String roomId;
  final bool refresh;
  LoadChatMessagesAction(this.roomId, {this.refresh = false});
}

class LoadChatMessagesSuccessAction {
  final String roomId;
  final List<ChatMessageResponse> messages;
  final bool hasMore;
  final int page;
  LoadChatMessagesSuccessAction({
    required this.roomId,
    required this.messages,
    required this.hasMore,
    required this.page,
  });
}

// --- 메시지 전송 관련 액션 ---
class SendMessageAction {
  final String roomId;
  final ChatMessageRequest request;
  SendMessageAction(this.roomId, this.request);
}

// --- 실시간 메시지 수신 액션 ---
// WebSocket 등에서 새 메시지를 받았을 때 사용
class ReceiveMessageAction {
  final ChatMessageResponse message;
  ReceiveMessageAction(this.message);
}

class CreateChatRoomAction {
  final int otherUserId;
  CreateChatRoomAction(this.otherUserId);
}

class CreateChatRoomSuccessAction {
  final ChatRoomResponse newRoom;
  CreateChatRoomSuccessAction(this.newRoom);
}
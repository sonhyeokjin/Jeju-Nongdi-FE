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

// --- WebSocket 연결 정보 관련 액션 ---
class LoadWebSocketInfoAction {}

class LoadWebSocketInfoSuccessAction {
  final WebSocketConnectionInfo wsInfo;
  LoadWebSocketInfoSuccessAction(this.wsInfo);
}

// --- 채팅방 목록 관련 액션 ---
class LoadChatRoomsAction {}

class LoadChatRoomsSuccessAction {
  final List<ChatRoomView> chatRooms;
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
  final List<MessageDto> messages;
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
  final MessageDto message;
  ReceiveMessageAction(this.message);
}

// --- 1:1 채팅방 생성/조회 관련 액션 ---
class GetOrCreateOneToOneRoomAction {
  final String targetEmail;
  GetOrCreateOneToOneRoomAction(this.targetEmail);
}

class GetOrCreateOneToOneRoomSuccessAction {
  final ChatRoomDto chatRoom;
  GetOrCreateOneToOneRoomSuccessAction(this.chatRoom);
}

// --- 채팅방 삭제 관련 액션 ---
class DeleteChatRoomAction {
  final String roomId;
  DeleteChatRoomAction(this.roomId);
}

class DeleteChatRoomSuccessAction {
  final String roomId;
  DeleteChatRoomSuccessAction(this.roomId);
}

// --- WebSocket 실시간 연결 관련 액션 ---
class ConnectWebSocketAction {}

class ConnectWebSocketSuccessAction {}

class DisconnectWebSocketAction {}

class JoinChatRoomAction {
  final String roomId;
  JoinChatRoomAction(this.roomId);
}

class LeaveChatRoomAction {
  final String roomId;
  LeaveChatRoomAction(this.roomId);
}


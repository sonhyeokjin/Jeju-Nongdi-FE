import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:jejunongdi/redux/chat/chat_state.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:redux/redux.dart';

final chatReducer = combineReducers<ChatState>([
  TypedReducer<ChatState, SetChatLoadingAction>(_setLoading),
  TypedReducer<ChatState, SetChatErrorAction>(_setError),
  TypedReducer<ChatState, LoadChatRoomsSuccessAction>(_loadChatRoomsSuccess),
  TypedReducer<ChatState, LoadChatMessagesAction>(_loadChatMessages),
  TypedReducer<ChatState, LoadChatMessagesSuccessAction>(_loadChatMessagesSuccess),
  TypedReducer<ChatState, ReceiveMessageAction>(_receiveMessage),
  TypedReducer<ChatState, CreateChatRoomSuccessAction>(_createChatRoomSuccess),
  TypedReducer<ChatState, MarkMessagesAsReadSuccessAction>(_markMessagesAsReadSuccess),
]);

ChatState _setLoading(ChatState state, SetChatLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading, error: null);
}

ChatState _setError(ChatState state, SetChatErrorAction action) {
  return state.copyWith(isLoading: false, error: action.error);
}

ChatState _loadChatRoomsSuccess(ChatState state, LoadChatRoomsSuccessAction action) {
  return state.copyWith(isLoading: false, chatRooms: action.chatRooms);
}

ChatState _loadChatMessages(ChatState state, LoadChatMessagesAction action) {
  if (action.refresh) {
    // [수정] Map 타입을 올바르게 유지합니다.
    final newMessages = Map<String, List<dynamic>>.from(state.messages)..remove(action.roomId);
    final newCurrentPage = Map<String, int>.from(state.currentPage)..remove(action.roomId);
    final newHasMoreMessages = Map<String, bool>.from(state.hasMoreMessages)..remove(action.roomId);
    return state.copyWith(
      isLoading: true,
      messages: newMessages.cast(), // [수정] cast() 메서드 사용
      currentPage: newCurrentPage,
      hasMoreMessages: newHasMoreMessages,
      error: null,
    );
  }
  return state.copyWith(isLoading: true, error: null);
}


ChatState _loadChatMessagesSuccess(ChatState state, LoadChatMessagesSuccessAction action) {
  // [수정] Map 타입을 올바르게 유지합니다.
  final newMessages = Map<String, List<dynamic>>.from(state.messages);
  final existingMessages = newMessages[action.roomId] ?? [];

  // 기존 메시지 목록에 새로운 메시지를 추가 (중복 방지)
  final messageIds = existingMessages.map((m) => m.messageId).toSet();
  final uniqueNewMessages = action.messages.where((m) => !messageIds.contains(m.messageId));

  // [수정] 이전 메시지(과거)는 뒤에, 새 메시지(최신)는 앞에 오도록 수정
  newMessages[action.roomId] = [...uniqueNewMessages, ...existingMessages];

  final newCurrentPage = Map<String, int>.from(state.currentPage);
  newCurrentPage[action.roomId] = action.page;

  final newHasMore = Map<String, bool>.from(state.hasMoreMessages);
  newHasMore[action.roomId] = action.hasMore;

  return state.copyWith(
    isLoading: false,
    messages: newMessages.cast(), // [수정] cast() 메서드 사용
    currentPage: newCurrentPage,
    hasMoreMessages: newHasMore,
  );
}

ChatState _receiveMessage(ChatState state, ReceiveMessageAction action) {
  // [수정] Map 타입을 올바르게 유지합니다.
  final newMessages = Map<String, List<dynamic>>.from(state.messages);
  final roomMessages = newMessages[action.message.roomId] ?? [];

  // 새 메시지를 맨 앞에 추가
  newMessages[action.message.roomId] = [action.message, ...roomMessages];

  return state.copyWith(messages: newMessages.cast()); // [수정] cast() 메서드 사용
}

ChatState _createChatRoomSuccess(ChatState state, CreateChatRoomSuccessAction action) {
  // 중복 추가 방지
  final alreadyExists = state.chatRooms.any((room) => room.roomId == action.newRoom.roomId);
  if (alreadyExists) {
    return state;
  }
  return state.copyWith(
    chatRooms: [action.newRoom, ...state.chatRooms],
  );
}

ChatState _markMessagesAsReadSuccess(ChatState state, MarkMessagesAsReadSuccessAction action) {
  // 메시지 읽음 처리 성공 시 해당 채팅방의 읽지 않은 메시지 수 초기화
  final updatedRooms = state.chatRooms.map((room) {
    if (room.roomId == action.roomId) {
      return ChatRoomResponse(
        roomId: room.roomId,
        roomName: room.roomName,
        otherUser: room.otherUser,
        lastMessage: room.lastMessage,
        lastMessageTime: room.lastMessageTime,
        unreadCount: 0, // 읽지 않은 메시지 수 초기화
      );
    }
    return room;
  }).toList();
  
  return state.copyWith(chatRooms: updatedRooms);
}
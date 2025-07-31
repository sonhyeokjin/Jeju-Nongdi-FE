import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:jejunongdi/redux/chat/chat_state.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:redux/redux.dart';

final chatReducer = combineReducers<ChatState>([
  TypedReducer<ChatState, SetChatLoadingAction>(_setLoading),
  TypedReducer<ChatState, SetChatErrorAction>(_setError),
  TypedReducer<ChatState, LoadWebSocketInfoSuccessAction>(_loadWebSocketInfoSuccess),
  TypedReducer<ChatState, LoadChatRoomsSuccessAction>(_loadChatRoomsSuccess),
  TypedReducer<ChatState, LoadChatMessagesAction>(_loadChatMessages),
  TypedReducer<ChatState, LoadChatMessagesSuccessAction>(_loadChatMessagesSuccess),
  TypedReducer<ChatState, ReceiveMessageAction>(_receiveMessage),
  TypedReducer<ChatState, GetOrCreateOneToOneRoomSuccessAction>(_getOrCreateOneToOneRoomSuccess),
  TypedReducer<ChatState, DeleteChatRoomSuccessAction>(_deleteChatRoomSuccess),
]);

ChatState _setLoading(ChatState state, SetChatLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading, error: null);
}

ChatState _setError(ChatState state, SetChatErrorAction action) {
  return state.copyWith(isLoading: false, error: action.error);
}

ChatState _loadWebSocketInfoSuccess(ChatState state, LoadWebSocketInfoSuccessAction action) {
  return state.copyWith(webSocketInfo: action.wsInfo);
}

ChatState _loadChatRoomsSuccess(ChatState state, LoadChatRoomsSuccessAction action) {
  return state.copyWith(isLoading: false, chatRooms: action.chatRooms);
}

ChatState _loadChatMessages(ChatState state, LoadChatMessagesAction action) {
  if (action.refresh) {
    final newMessages = Map<String, List<MessageDto>>.from(state.messages)..remove(action.roomId);
    final newCurrentPage = Map<String, int>.from(state.currentPage)..remove(action.roomId);
    final newHasMoreMessages = Map<String, bool>.from(state.hasMoreMessages)..remove(action.roomId);
    return state.copyWith(
      isLoading: true,
      messages: newMessages,
      currentPage: newCurrentPage,
      hasMoreMessages: newHasMoreMessages,
      error: null,
    );
  }
  return state.copyWith(isLoading: true, error: null);
}

ChatState _loadChatMessagesSuccess(ChatState state, LoadChatMessagesSuccessAction action) {
  final newMessages = Map<String, List<MessageDto>>.from(state.messages);
  final existingMessages = newMessages[action.roomId] ?? [];

  // 기존 메시지 목록에 새로운 메시지를 추가 (중복 방지)
  final messageIds = existingMessages.map((m) => m.messageId).toSet();
  final uniqueNewMessages = action.messages.where((m) => !messageIds.contains(m.messageId));

  // 시간순으로 정렬 (최신 메시지가 앞에 오도록)
  final allMessages = [...uniqueNewMessages, ...existingMessages];
  allMessages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
  
  newMessages[action.roomId] = allMessages;

  final newCurrentPage = Map<String, int>.from(state.currentPage);
  newCurrentPage[action.roomId] = action.page;

  final newHasMore = Map<String, bool>.from(state.hasMoreMessages);
  newHasMore[action.roomId] = action.hasMore;

  return state.copyWith(
    isLoading: false,
    messages: newMessages,
    currentPage: newCurrentPage,
    hasMoreMessages: newHasMore,
  );
}

ChatState _receiveMessage(ChatState state, ReceiveMessageAction action) {
  final newMessages = Map<String, List<MessageDto>>.from(state.messages);
  final roomMessages = newMessages[action.message.roomId] ?? [];

  // 중복 방지
  final messageExists = roomMessages.any((m) => m.messageId == action.message.messageId);
  if (!messageExists) {
    // 새 메시지를 맨 앞에 추가
    newMessages[action.message.roomId] = [action.message, ...roomMessages];
  }

  return state.copyWith(messages: newMessages);
}

ChatState _getOrCreateOneToOneRoomSuccess(ChatState state, GetOrCreateOneToOneRoomSuccessAction action) {
  final newOneToOneRooms = Map<String, ChatRoomDto>.from(state.oneToOneRooms);
  
  // targetEmail을 키로 사용하여 저장 (participants에서 현재 사용자가 아닌 사용자의 이메일 추출)
  final participants = action.chatRoom.participants;
  String? targetEmail;
  
  // 안전하게 이메일 추출
  try {
    if (participants.isNotEmpty) {
      final firstParticipant = participants.first;
      // 이메일이 null이 아닌지 확인
      if (firstParticipant.email != null && firstParticipant.email!.isNotEmpty) {
        targetEmail = firstParticipant.email!;
      }
    }
  } catch (e) {
    // 참가자 정보 추출 중 오류 발생 시 로그 출력하고 계속 진행
    print('Error extracting participant email: $e');
  }
  
  // targetEmail이 유효한 경우에만 저장
  if (targetEmail != null && targetEmail.isNotEmpty) {
    newOneToOneRooms[targetEmail] = action.chatRoom;
  }

  return state.copyWith(oneToOneRooms: newOneToOneRooms);
}

ChatState _deleteChatRoomSuccess(ChatState state, DeleteChatRoomSuccessAction action) {
  // 채팅방 목록에서 삭제된 채팅방 제거
  final updatedRooms = state.chatRooms.where((room) => room.roomId != action.roomId).toList();
  
  // 메시지 목록에서도 해당 채팅방의 메시지 제거
  final newMessages = Map<String, List<MessageDto>>.from(state.messages)..remove(action.roomId);
  final newCurrentPage = Map<String, int>.from(state.currentPage)..remove(action.roomId);
  final newHasMoreMessages = Map<String, bool>.from(state.hasMoreMessages)..remove(action.roomId);

  return state.copyWith(
    chatRooms: updatedRooms,
    messages: newMessages,
    currentPage: newCurrentPage,
    hasMoreMessages: newHasMoreMessages,
  );
}
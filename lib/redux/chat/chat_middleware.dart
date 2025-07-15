// lib/redux/chat/chat_middleware.dart

import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/core/services/chat_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createChatMiddleware() {
  final chatService = ChatService.instance;

  // [수정] 모든 미들웨어 함수를 올바른 구조로 다시 정의합니다.
  return [
    TypedMiddleware<AppState, LoadChatRoomsAction>(_loadChatRooms(chatService)),
    TypedMiddleware<AppState, LoadChatMessagesAction>(_loadChatMessages(chatService)),
    TypedMiddleware<AppState, SendMessageAction>(_sendMessage(chatService)),
    TypedMiddleware<AppState, CreateChatRoomAction>(_createChatRoom(chatService)),
  ];
}

void Function(Store<AppState> store, LoadChatRoomsAction action, NextDispatcher next)
_loadChatRooms(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.getChatRooms();
    result.onSuccess((chatRooms) {
      store.dispatch(LoadChatRoomsSuccessAction(chatRooms));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
    });
  };
}

void Function(Store<AppState> store, LoadChatMessagesAction action, NextDispatcher next)
_loadChatMessages(ChatService service) {
  return (store, action, next) async {
    next(action);

    if (store.state.chatState.isLoading) return;

    final currentRoomState = store.state.chatState;
    final currentPage = action.refresh ? 0 : currentRoomState.currentPage[action.roomId] ?? -1;
    final hasMore = currentRoomState.hasMoreMessages[action.roomId] ?? true;

    if (!action.refresh && !hasMore) return;

    final result = await service.getChatMessages(roomId: action.roomId, page: action.refresh ? 0 : currentPage + 1);
    result.onSuccess((pageResponse) {
      store.dispatch(LoadChatMessagesSuccessAction(
        roomId: action.roomId,
        messages: pageResponse.content,
        hasMore: !pageResponse.last,
        page: pageResponse.number,
      ));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
    });
  };
}

void Function(Store<AppState> store, SendMessageAction action, NextDispatcher next)
_sendMessage(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.sendMessage(roomId: action.roomId, request: action.request);

    result.onSuccess((message) {
      store.dispatch(ReceiveMessageAction(message));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('메시지 전송 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, CreateChatRoomAction action, NextDispatcher next)
_createChatRoom(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.createChatRoom(
      request: ChatRoomCreateRequest(otherUserId: action.otherUserId),
    );
    result.onSuccess((newRoom) {
      store.dispatch(CreateChatRoomSuccessAction(newRoom));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
    });
  };
}
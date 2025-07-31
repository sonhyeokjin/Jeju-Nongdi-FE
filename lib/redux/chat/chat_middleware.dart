// lib/redux/chat/chat_middleware.dart

import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/core/services/chat_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createChatMiddleware() {
  final chatService = ChatService.instance;

  return [
    TypedMiddleware<AppState, LoadWebSocketInfoAction>(_loadWebSocketInfo(chatService)),
    TypedMiddleware<AppState, LoadChatRoomsAction>(_loadChatRooms(chatService)),
    TypedMiddleware<AppState, LoadChatMessagesAction>(_loadChatMessages(chatService)),
    TypedMiddleware<AppState, SendMessageAction>(_sendMessage(chatService)),
    TypedMiddleware<AppState, GetOrCreateOneToOneRoomAction>(_getOrCreateOneToOneRoom(chatService)),
    TypedMiddleware<AppState, DeleteChatRoomAction>(_deleteChatRoom(chatService)),
    TypedMiddleware<AppState, CreateDummyChatRoomsAction>(_createDummyChatRooms(chatService)),
    TypedMiddleware<AppState, CreateDummyMessagesAction>(_createDummyMessages(chatService)),
  ];
}

void Function(Store<AppState> store, LoadWebSocketInfoAction action, NextDispatcher next)
_loadWebSocketInfo(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.getWebSocketInfo();
    result.onSuccess((wsInfo) {
      store.dispatch(LoadWebSocketInfoSuccessAction(wsInfo));
      store.dispatch(SetChatLoadingAction(false));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
      store.dispatch(SetChatLoadingAction(false));
    });
  };
}

void Function(Store<AppState> store, LoadChatRoomsAction action, NextDispatcher next)
_loadChatRooms(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.getChatRooms();
    result.onSuccess((chatRooms) {
      store.dispatch(LoadChatRoomsSuccessAction(chatRooms));
      store.dispatch(SetChatLoadingAction(false));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
      store.dispatch(SetChatLoadingAction(false));
    });
  };
}

void Function(Store<AppState> store, LoadChatMessagesAction action, NextDispatcher next)
_loadChatMessages(ChatService service) {
  return (store, action, next) async {
    next(action);

    if (store.state.chatState.isLoading) return;

    store.dispatch(SetChatLoadingAction(true));
    
    final result = await service.getChatMessages(roomId: action.roomId);
    result.onSuccess((messages) {
      store.dispatch(LoadChatMessagesSuccessAction(
        roomId: action.roomId,
        messages: messages,
        hasMore: false, // 전체 메시지 조회이므로 hasMore는 false
        page: 0,
      ));
      store.dispatch(SetChatLoadingAction(false));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
      store.dispatch(SetChatLoadingAction(false));
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

void Function(Store<AppState> store, GetOrCreateOneToOneRoomAction action, NextDispatcher next)
_getOrCreateOneToOneRoom(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.getOrCreateOneToOneRoom(targetEmail: action.targetEmail);
    result.onSuccess((chatRoom) {
      store.dispatch(GetOrCreateOneToOneRoomSuccessAction(chatRoom));
      // 채팅방 생성/조회 성공 후 해당 채팅방의 메시지 자동 로드
      store.dispatch(LoadChatMessagesAction(chatRoom.roomId, refresh: true));
      store.dispatch(SetChatLoadingAction(false));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
      store.dispatch(SetChatLoadingAction(false));
    });
  };
}

void Function(Store<AppState> store, DeleteChatRoomAction action, NextDispatcher next)
_deleteChatRoom(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.deleteChatRoom(roomId: action.roomId);
    result.onSuccess((_) {
      store.dispatch(DeleteChatRoomSuccessAction(action.roomId));
      // 채팅방 삭제 후 목록 새로고침
      store.dispatch(LoadChatRoomsAction());
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('채팅방 삭제 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, CreateDummyChatRoomsAction action, NextDispatcher next)
_createDummyChatRooms(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.createDummyChatRooms();
    result.onSuccess((dummyChatRooms) {
      store.dispatch(CreateDummyChatRoomsSuccessAction(dummyChatRooms));
      store.dispatch(SetChatLoadingAction(false));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('더미 채팅방 생성 실패: ${error.message}'));
      store.dispatch(SetChatLoadingAction(false));
    });
  };
}

void Function(Store<AppState> store, CreateDummyMessagesAction action, NextDispatcher next)
_createDummyMessages(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.createDummyMessages(action.roomId);
    result.onSuccess((dummyMessages) {
      store.dispatch(CreateDummyMessagesSuccessAction(action.roomId, dummyMessages));
      store.dispatch(SetChatLoadingAction(false));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('더미 메시지 생성 실패: ${error.message}'));
      store.dispatch(SetChatLoadingAction(false));
    });
  };
}
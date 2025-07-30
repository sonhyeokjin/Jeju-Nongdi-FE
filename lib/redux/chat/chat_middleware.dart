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
    TypedMiddleware<AppState, MarkMessagesAsReadAction>(_markMessagesAsRead(chatService)),
    TypedMiddleware<AppState, EnterChatRoomAction>(_enterChatRoom(chatService)),
    TypedMiddleware<AppState, LeaveChatRoomAction>(_leaveChatRoom(chatService)),
    TypedMiddleware<AppState, SendFileMessageAction>(_sendFileMessage(chatService)),
    TypedMiddleware<AppState, LoadUnreadCountAction>(_loadUnreadCount(chatService)),
    TypedMiddleware<AppState, LoadChatRoomsByTypeAction>(_loadChatRoomsByType(chatService)),
    TypedMiddleware<AppState, SearchChatRoomsAction>(_searchChatRooms(chatService)),
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
      request: ChatRoomCreateRequest(
        chatType: action.chatType,
        participantId: action.participantId,
        referenceId: action.referenceId,
        initialMessage: action.initialMessage,
      ),
    );
    result.onSuccess((newRoom) {
      store.dispatch(CreateChatRoomSuccessAction(newRoom));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction(error.message));
    });
  };
}

void Function(Store<AppState> store, MarkMessagesAsReadAction action, NextDispatcher next)
_markMessagesAsRead(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.markMessagesAsRead(roomId: action.roomId);
    result.onSuccess((_) {
      store.dispatch(MarkMessagesAsReadSuccessAction(action.roomId));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('메시지 읽음 처리 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, EnterChatRoomAction action, NextDispatcher next)
_enterChatRoom(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.enterChatRoom(roomId: action.roomId);
    result.onSuccess((_) {
      // 채팅방 입장 후 메시지 읽음 처리
      store.dispatch(MarkMessagesAsReadAction(action.roomId));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('채팅방 입장 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, LeaveChatRoomAction action, NextDispatcher next)
_leaveChatRoom(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.leaveChatRoom(roomId: action.roomId);
    result.onSuccess((_) {
      // 채팅방 나가기 성공 시 채팅방 목록 새로고침
      store.dispatch(LoadChatRoomsAction());
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('채팅방 나가기 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, SendFileMessageAction action, NextDispatcher next)
_sendFileMessage(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.sendMessageWithFile(
      roomId: action.roomId,
      filePath: action.filePath,
      content: action.content,
    );
    result.onSuccess((message) {
      store.dispatch(ReceiveMessageAction(message));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('파일 메시지 전송 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, LoadUnreadCountAction action, NextDispatcher next)
_loadUnreadCount(ChatService service) {
  return (store, action, next) async {
    next(action);
    final result = await service.getUnreadCount();
    result.onSuccess((count) {
      store.dispatch(LoadUnreadCountSuccessAction(count));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('읽지 않은 메시지 개수 조회 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, LoadChatRoomsByTypeAction action, NextDispatcher next)
_loadChatRoomsByType(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.getChatRoomsByType(
      chatType: action.chatType,
      page: action.page,
      size: action.size,
    );
    result.onSuccess((chatRooms) {
      store.dispatch(LoadChatRoomsSuccessAction(chatRooms));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('타입별 채팅방 조회 실패: ${error.message}'));
    });
  };
}

void Function(Store<AppState> store, SearchChatRoomsAction action, NextDispatcher next)
_searchChatRooms(ChatService service) {
  return (store, action, next) async {
    next(action);
    store.dispatch(SetChatLoadingAction(true));
    final result = await service.searchChatRooms(
      query: action.query,
      page: action.page,
      size: action.size,
    );
    result.onSuccess((chatRooms) {
      store.dispatch(LoadChatRoomsSuccessAction(chatRooms));
    }).onFailure((error) {
      store.dispatch(SetChatErrorAction('채팅방 검색 실패: ${error.message}'));
    });
  };
}
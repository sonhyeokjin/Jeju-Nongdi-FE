// lib/redux/chat/chat_middleware.dart

import 'dart:async';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/core/services/chat_service.dart';
import 'package:jejunongdi/core/services/websocket_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createChatMiddleware() {
  final chatService = ChatService.instance;
  final webSocketService = WebSocketService.instance;

  return [
    TypedMiddleware<AppState, LoadWebSocketInfoAction>(_loadWebSocketInfo(chatService)),
    TypedMiddleware<AppState, LoadChatRoomsAction>(_loadChatRooms(chatService)),
    TypedMiddleware<AppState, LoadChatMessagesAction>(_loadChatMessages(chatService)),
    TypedMiddleware<AppState, SendMessageAction>(_sendMessage(chatService, webSocketService)),
    TypedMiddleware<AppState, GetOrCreateOneToOneRoomAction>(_getOrCreateOneToOneRoom(chatService)),
    TypedMiddleware<AppState, DeleteChatRoomAction>(_deleteChatRoom(chatService)),
    TypedMiddleware<AppState, ConnectWebSocketAction>(_connectWebSocket(webSocketService)),
    TypedMiddleware<AppState, DisconnectWebSocketAction>(_disconnectWebSocket(webSocketService)),
    TypedMiddleware<AppState, JoinChatRoomAction>(_joinChatRoom(webSocketService)),
    TypedMiddleware<AppState, LeaveChatRoomAction>(_leaveChatRoom(webSocketService)),
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
_sendMessage(ChatService service, WebSocketService webSocketService) {
  return (store, action, next) async {
    next(action);
    print('🚀 SendMessageAction 실행: roomId=${action.roomId}, content=${action.request.content}');

    if (webSocketService.isConnected) {
      print('✅ WebSocket 연결됨, 메시지 전송 시도');
      // WebSocket을 통해 메시지 전송 (낙관적 업데이트 제거)
      final success = await webSocketService.sendMessage(
        roomId: action.roomId,
        content: action.request.content,
      );

      if (!success) {
        print('❌ WebSocket 메시지 전송 실패');
        store.dispatch(SetChatErrorAction('메시지 전송에 실패했습니다.'));
      } else {
        print('✅ WebSocket 메시지 전송 성공');
      }
    } else {
      print('❌ WebSocket 연결 안됨, HTTP API로 폴백');
      // WebSocket이 연결되지 않은 경우 HTTP API로 폴백
      store.dispatch(SetChatLoadingAction(true));
      final result = await service.sendMessage(
        roomId: action.roomId,
        request: action.request,
      );
      
      result.onSuccess((message) {
        print('✅ HTTP API 메시지 전송 성공: ${message.id}');
        store.dispatch(ReceiveMessageAction(message));
        store.dispatch(SetChatLoadingAction(false));
      }).onFailure((error) {
        print('❌ HTTP API 메시지 전송 실패: ${error.message}');
        store.dispatch(SetChatErrorAction(error.message));
        store.dispatch(SetChatLoadingAction(false));
      });
    }
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


// WebSocket 관련 미들웨어들
StreamSubscription<MessageDto>? _webSocketStreamSubscription;

void Function(Store<AppState> store, ConnectWebSocketAction action, NextDispatcher next)
_connectWebSocket(WebSocketService webSocketService) {
  return (store, action, next) async {
    next(action);
    print('🔌 WebSocket 연결 시도 중...');
    
    // 기존 구독이 있다면 취소
    _webSocketStreamSubscription?.cancel();
    
    final success = await webSocketService.connect();
    print('🔌 WebSocket 연결 결과: $success');
    if (success) {
      store.dispatch(ConnectWebSocketSuccessAction());
      // WebSocket 메시지 스트림 리스닝 시작 (중복 방지)
      _webSocketStreamSubscription = webSocketService.messageStream.listen((message) {
        print('📨 WebSocket 메시지 수신: roomId=${message.roomId}, messageId=${message.id}, content=${message.content}');
        store.dispatch(ReceiveMessageAction(message));
      });
      print('👂 WebSocket 메시지 스트림 리스너 등록 완료');
    } else {
      print('❌ WebSocket 연결 실패');
      store.dispatch(SetChatErrorAction('WebSocket 연결 실패'));
    }
  };
}

void Function(Store<AppState> store, DisconnectWebSocketAction action, NextDispatcher next)
_disconnectWebSocket(WebSocketService webSocketService) {
  return (store, action, next) async {
    next(action);
    // 스트림 구독 취소
    _webSocketStreamSubscription?.cancel();
    _webSocketStreamSubscription = null;
    webSocketService.disconnect();
  };
}

void Function(Store<AppState> store, JoinChatRoomAction action, NextDispatcher next)
_joinChatRoom(WebSocketService webSocketService) {
  return (store, action, next) async {
    next(action);
    print('🏠 채팅방 입장 시도: roomId=${action.roomId}');
    final success = await webSocketService.joinRoom(action.roomId);
    print('🏠 채팅방 입장 결과: $success');
  };
}

void Function(Store<AppState> store, LeaveChatRoomAction action, NextDispatcher next)
_leaveChatRoom(WebSocketService webSocketService) {
  return (store, action, next) async {
    next(action);
    await webSocketService.leaveRoom(action.roomId);
  };
}
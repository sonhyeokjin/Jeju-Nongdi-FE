// lib/core/services/chat_service.dart

import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // PageResponse 재사용
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class ChatService {
  static ChatService? _instance;
  final ApiClient _apiClient = ApiClient.instance;

  static ChatService get instance {
    _instance ??= ChatService._internal();
    return _instance!;
  }

  ChatService._internal();

  /// WebSocket 연결 정보 조회
  Future<ApiResult<WebSocketConnectionInfo>> getWebSocketInfo() async {
    try {
      Logger.info('WebSocket 연결 정보 조회 시도');
      final response = await _apiClient.get<Map<String, dynamic>>('/api/chat/websocket-info');

      if (response.data != null) {
        // API 응답에서 실제 데이터 부분 추출
        final responseData = response.data!;
        final actualData = responseData['data'] as Map<String, dynamic>;
        
        final wsInfo = WebSocketConnectionInfo.fromJson(actualData);
        Logger.info('WebSocket 연결 정보 조회 성공');
        return ApiResult.success(wsInfo);
      } else {
        return ApiResult.failure(const UnknownException('WebSocket 연결 정보가 없습니다.'));
      }
    } catch (e) {
      Logger.error('WebSocket 연결 정보 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 현재 사용자가 참여중인 채팅방 목록 조회 (새로운 API 스펙)
  Future<ApiResult<List<ChatRoomView>>> getChatRooms() async {
    try {
      Logger.info('채팅방 목록 조회 시도');
      final response = await _apiClient.get<Map<String, dynamic>>('/api/chat/rooms');

      if (response.data != null) {
        // API 응답 구조 확인 후 적절히 처리
        final responseData = response.data!;
        print('📊 채팅방 목록 API 응답: $responseData');
        
        List<dynamic>? roomsData;
        
        if (responseData.containsKey('data')) {
          // 래핑된 구조인 경우
          final data = responseData['data'];
          if (data is List) {
            roomsData = data;
          } else {
            print('❌ data 필드가 List가 아님: ${data.runtimeType}');
            Logger.error('data 필드가 List 타입이 아닙니다: ${data.runtimeType}');
            return ApiResult.failure(const UnknownException('올바르지 않은 응답 형식입니다.'));
          }
        } else {
          // 직접 리스트인 경우
          if (response.data is List) {
            roomsData = response.data as List<dynamic>;
          } else {
            print('❌ 응답 데이터가 List가 아님: ${response.data.runtimeType}');
            Logger.error('응답 데이터가 List 타입이 아닙니다: ${response.data.runtimeType}');
            return ApiResult.failure(const UnknownException('올바르지 않은 응답 형식입니다.'));
          }
        }
        
        if (roomsData == null) {
          Logger.info('채팅방 목록이 비어있습니다.');
          return ApiResult.success([]);
        }
        
        final chatRooms = <ChatRoomView>[];
        for (int i = 0; i < roomsData.length; i++) {
          try {
            final item = roomsData[i];
            if (item is Map<String, dynamic>) {
              chatRooms.add(ChatRoomView.fromJson(item));
            } else {
              print('❌ 채팅방 데이터[$i]가 Map이 아님: ${item.runtimeType}');
              Logger.error('채팅방 데이터[$i]가 Map 타입이 아닙니다: ${item.runtimeType}');
            }
          } catch (e) {
            print('❌ 채팅방 데이터[$i] 파싱 실패: $e');
            Logger.error('채팅방 데이터[$i] 파싱 실패', error: e);
          }
        }

        Logger.info('채팅방 목록 조회 성공: ${chatRooms.length}개');
        return ApiResult.success(chatRooms);
      } else {
        return ApiResult.failure(const UnknownException('채팅방 목록 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('채팅방 목록 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 특정 채팅방의 메시지 목록 조회 (전체)
  Future<ApiResult<List<MessageDto>>> getChatMessages({
    required String roomId,
  }) async {
    try {
      Logger.info('채팅 메시지 목록 조회 시도: roomId=$roomId');
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/chat/rooms/$roomId/messages',
      );

      if (response.data != null) {
        // API 응답 구조 확인 후 적절히 처리
        final responseData = response.data!;
        print('📊 채팅 메시지 API 응답: $responseData');
        
        List<dynamic>? messagesData;
        
        if (responseData.containsKey('data')) {
          // 래핑된 구조인 경우
          final data = responseData['data'];
          if (data is List) {
            messagesData = data;
          } else {
            print('❌ 메시지 data 필드가 List가 아님: ${data.runtimeType}');
            Logger.error('메시지 data 필드가 List 타입이 아닙니다: ${data.runtimeType}');
            return ApiResult.failure(const UnknownException('올바르지 않은 메시지 응답 형식입니다.'));
          }
        } else {
          // 직접 리스트인 경우
          if (response.data is List) {
            messagesData = response.data as List<dynamic>;
          } else {
            print('❌ 메시지 응답 데이터가 List가 아님: ${response.data.runtimeType}');
            Logger.error('메시지 응답 데이터가 List 타입이 아닙니다: ${response.data.runtimeType}');
            return ApiResult.failure(const UnknownException('올바르지 않은 메시지 응답 형식입니다.'));
          }
        }
        
        if (messagesData == null) {
          Logger.info('메시지 목록이 비어있습니다.');
          return ApiResult.success([]);
        }
        
        final messages = <MessageDto>[];
        for (int i = 0; i < messagesData.length; i++) {
          try {
            final item = messagesData[i];
            if (item is Map<String, dynamic>) {
              final convertedMessage = _convertApiMessageToDto(item);
              if (convertedMessage != null) {
                messages.add(convertedMessage);
              }
            } else {
              print('❌ 메시지 데이터[$i]가 Map이 아님: ${item.runtimeType}');
              Logger.error('메시지 데이터[$i]가 Map 타입이 아닙니다: ${item.runtimeType}');
            }
          } catch (e) {
            print('❌ 메시지 데이터[$i] 파싱 실패: $e');
            Logger.error('메시지 데이터[$i] 파싱 실패', error: e);
          }
        }
        
        Logger.info('채팅 메시지 목록 조회 성공: ${messages.length}개');
        return ApiResult.success(messages);
      } else {
        return ApiResult.failure(const UnknownException('메시지 목록 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('채팅 메시지 목록 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 특정 채팅방의 메시지 목록 조회 (페이징)
  Future<ApiResult<PageResponse<MessageDto>>> getChatMessagesPaged({
    required String roomId,
    int page = 0,
    int size = 30,
  }) async {
    try {
      Logger.info('채팅 메시지 페이징 조회 시도: roomId=$roomId, page=$page');
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/chat/rooms/$roomId/messages/paged',
        queryParameters: {'page': page, 'size': size, 'sort': 'sentAt,desc'},
      );

      if (response.data != null) {
        final pageResponse = PageResponse<MessageDto>.fromJson(
          response.data!,
              (json) => MessageDto.fromJson(json as Map<String, dynamic>),
        );
        Logger.info('채팅 메시지 페이징 조회 성공: ${pageResponse.content.length}개');
        return ApiResult.success(pageResponse);
      } else {
        return ApiResult.failure(const UnknownException('메시지 목록 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('채팅 메시지 페이징 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 1:1 채팅방 조회 또는 생성
  Future<ApiResult<ChatRoomDto>> getOrCreateOneToOneRoom({
    required String targetEmail,
  }) async {
    try {
      Logger.info('1:1 채팅방 조회/생성 시도: targetEmail=$targetEmail');
      
      // targetEmail이 비어있거나 null인 경우 체크
      if (targetEmail.trim().isEmpty) {
        Logger.error('1:1 채팅방 조회/생성 실패: 대상 이메일이 비어있음');
        return ApiResult.failure(const UnknownException('대상 이메일이 비어있습니다.'));
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/chat/room',
        queryParameters: {'targetEmail': targetEmail.trim()},
      );

      if (response.data != null) {
        try {
          // API 응답 구조 로깅
          Logger.info('1:1 채팅방 API 응답: ${response.data}');
          
          // API 응답에서 실제 데이터 부분 추출
          final responseData = response.data!;
          final actualData = responseData['data'] as Map<String, dynamic>;
          
          // OneToOneChatRoomDto로 파싱
          final oneToOneRoom = OneToOneChatRoomDto.fromJson(actualData);
          
          // ChatRoomDto로 변환 (앱에서 사용하는 형태)
          final chatRoom = ChatRoomDto(
            roomId: oneToOneRoom.roomId,
            roomName: null, // 1:1 채팅방은 roomName이 없음
            chatType: 'GENERAL', // 기본값
            participants: [
              // otherUser 정보를 UserResponse로 변환
              UserResponse(
                id: oneToOneRoom.user1Id, // 상대방 ID
                name: oneToOneRoom.otherUserNickname,
                profileImageUrl: oneToOneRoom.otherUserProfileImage,
                email: targetEmail, // targetEmail 사용
              ),
            ],
            lastMessage: null,
            lastMessageTime: null,
            unreadCount: 0,
            createdAt: oneToOneRoom.createdAt,
            updatedAt: null,
          );
          
          Logger.info('1:1 채팅방 조회/생성 성공: roomId=${chatRoom.roomId}');
          return ApiResult.success(chatRoom);
        } catch (parseError, stackTrace) {
          Logger.error(
            '1:1 채팅방 응답 파싱 실패', 
            error: parseError, 
            stackTrace: stackTrace,
          );
          Logger.error('실제 응답 데이터: ${response.data}');
          return ApiResult.failure(UnknownException('채팅방 정보를 받아오는 데 실패했습니다. 오류: $parseError'));
        }
      } else {
        return ApiResult.failure(const UnknownException('1:1 채팅방 조회/생성 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('1:1 채팅방 조회/생성 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 채팅방 삭제
  Future<ApiResult<void>> deleteChatRoom({required String roomId}) async {
    try {
      Logger.info('채팅방 삭제 시도: roomId=$roomId');
      await _apiClient.delete('/api/chat/rooms/$roomId');
      Logger.info('채팅방 삭제 성공: roomId=$roomId');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('채팅방 삭제 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 텍스트 메시지 전송
  Future<ApiResult<MessageDto>> sendMessage({
    required String roomId,
    required ChatMessageRequest request,
  }) async {
    try {
      Logger.info('메시지 전송 시도: roomId=$roomId');
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/chat/rooms/$roomId/messages',
        data: request.toJson(),
      );
      if (response.data != null) {
        // API 응답 구조 확인 후 적절히 처리
        final responseData = response.data!;
        Map<String, dynamic> messageData;
        
        if (responseData.containsKey('data')) {
          // 래핑된 구조인 경우
          messageData = responseData['data'] as Map<String, dynamic>;
        } else {
          // 직접 객체인 경우
          messageData = response.data!;
        }
        
        final message = _convertApiMessageToDto(messageData);
        if (message != null) {
          Logger.info('메시지 전송 성공');
          return ApiResult.success(message);
        } else {
          Logger.error('메시지 전송 응답 파싱 실패');
          return ApiResult.failure(const UnknownException('메시지 전송 응답 파싱에 실패했습니다.'));
        }
      } else {
        return ApiResult.failure(const UnknownException('메시지 전송 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('메시지 전송 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// API 메시지를 MessageDto로 변환
  MessageDto? _convertApiMessageToDto(Map<String, dynamic> apiMessage) {
    try {
      print('📊 API 메시지 원본: $apiMessage');
      
      // API 메시지 구조와 MessageDto 구조 차이를 처리
      
      // senderId가 int인지 UserResponse인지 확인
      dynamic senderData = apiMessage['senderId'];
      UserResponse senderUserResponse;
      
      if (senderData is int) {
        // senderId가 int인 경우, 추가 정보로 UserResponse 생성
        senderUserResponse = UserResponse(
          id: senderData,
          name: apiMessage['senderNickname'] ?? 'Unknown',
          email: apiMessage['email'] ?? '',
          profileImageUrl: apiMessage['senderProfileImage'],
        );
      } else if (senderData is Map<String, dynamic>) {
        // senderId가 UserResponse 객체인 경우
        senderUserResponse = UserResponse.fromJson(senderData);
      } else {
        print('❌ senderId 타입을 알 수 없음: ${senderData.runtimeType}');
        return null;
      }
      
      // id가 int인 경우 String으로 변환
      String messageId;
      dynamic idData = apiMessage['id'];
      if (idData is int) {
        messageId = idData.toString();
      } else if (idData is String) {
        messageId = idData;
      } else {
        print('❌ id 타입을 알 수 없음: ${idData.runtimeType}');
        return null;
      }
      
      // createdAt 파싱
      DateTime createdAt;
      try {
        dynamic createdAtData = apiMessage['createdAt'] ?? apiMessage['sentAt'];
        if (createdAtData is String) {
          createdAt = DateTime.parse(createdAtData);
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        print('⚠️ createdAt 파싱 실패, 현재 시간 사용: $e');
        createdAt = DateTime.now();
      }
      
      return MessageDto(
        id: messageId,
        roomId: apiMessage['roomId']?.toString() ?? '',
        senderId: senderUserResponse,
        email: apiMessage['email'] ?? '',
        content: apiMessage['content'] ?? '',
        messageType: apiMessage['messageType'] ?? 'TEXT',
        createdAt: createdAt,
        isRead: apiMessage['isRead'] ?? false,
        fileUrl: apiMessage['fileUrl'],
        senderProfileImage: apiMessage['senderProfileImage'],
      );
    } catch (e) {
      print('❌ API 메시지 변환 오류: $e');
      print('📊 변환 시도한 데이터: $apiMessage');
      return null;
    }
  }
}
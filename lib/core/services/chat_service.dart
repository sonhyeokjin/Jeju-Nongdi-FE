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

  /// 현재 사용자가 참여중인 채팅방 목록 조회
  Future<ApiResult<List<ChatRoomResponse>>> getChatRooms() async {
    try {
      Logger.info('채팅방 목록 조회 시도');
      // [수정] 서버가 객체(Map) 형태로 응답하므로, 받는 타입도 Map<String, dynamic>으로 변경합니다.
      final response = await _apiClient.get<Map<String, dynamic>>('/api/chat/rooms');

      if (response.data != null) {
        // [수정] Map으로 받은 데이터에서 'content' 키를 통해 실제 리스트 데이터를 추출합니다.
        final List<dynamic> chatRoomsData = response.data!['content'] ?? [];

        final chatRooms = chatRoomsData
            .map((item) => ChatRoomResponse.fromJson(item as Map<String, dynamic>))
            .toList();

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

  /// 특정 채팅방의 메시지 목록 조회 (페이징)
  Future<ApiResult<PageResponse<ChatMessageResponse>>> getChatMessages({
    required String roomId,
    int page = 0,
    int size = 30,
  }) async {
    try {
      Logger.info('채팅 메시지 목록 조회 시도: roomId=$roomId, page=$page');
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/chat/rooms/$roomId/messages',
        queryParameters: {'page': page, 'size': size, 'sort': 'sentAt,desc'},
      );

      if (response.data != null) {
        final pageResponse = PageResponse<ChatMessageResponse>.fromJson(
          response.data!,
              (json) => ChatMessageResponse.fromJson(json as Map<String, dynamic>),
        );
        Logger.info('채팅 메시지 목록 조회 성공: ${pageResponse.content.length}개');
        return ApiResult.success(pageResponse);
      } else {
        return ApiResult.failure(const UnknownException('메시지 목록 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('채팅 메시지 목록 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 텍스트 메시지 전송
  Future<ApiResult<ChatMessageResponse>> sendMessage({
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
        final message = ChatMessageResponse.fromJson(response.data!);
        Logger.info('메시지 전송 성공');
        return ApiResult.success(message);
      } else {
        return ApiResult.failure(const UnknownException('메시지 전송 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('메시지 전송 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 채팅방 생성
  Future<ApiResult<ChatRoomResponse>> createChatRoom({
    required ChatRoomCreateRequest request,
  }) async {
    try {
      Logger.info('채팅방 생성 시도: otherUserId=${request.otherUserId}');
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/chat/rooms',
        data: request.toJson(),
      );
      if (response.data != null) {
        final chatRoom = ChatRoomResponse.fromJson(response.data!);
        Logger.info('채팅방 생성 성공: roomId=${chatRoom.roomId}');
        return ApiResult.success(chatRoom);
      } else {
        return ApiResult.failure(const UnknownException('채팅방 생성 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('채팅방 생성 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  Future<ApiResult<void>> enterChatRoom({required String roomId}) async {
    try {
      await _apiClient.post('/api/chat/rooms/$roomId/enter');
      Logger.info('채팅방 입장 성공: roomId=$roomId');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('채팅방 입장 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  // [추가] 채팅방 나가기
  Future<ApiResult<void>> leaveChatRoom({required String roomId}) async {
    try {
      await _apiClient.post('/api/chat/rooms/$roomId/leave');
      Logger.info('채팅방 나가기 성공: roomId=$roomId');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('채팅방 나가기 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }
}
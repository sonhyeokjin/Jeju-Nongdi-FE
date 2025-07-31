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
        final wsInfo = WebSocketConnectionInfo.fromJson(response.data!);
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
      final response = await _apiClient.get<List<dynamic>>('/api/chat/rooms');

      if (response.data != null) {
        final chatRooms = response.data!
            .map((item) => ChatRoomView.fromJson(item as Map<String, dynamic>))
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

  /// 특정 채팅방의 메시지 목록 조회 (전체)
  Future<ApiResult<List<MessageDto>>> getChatMessages({
    required String roomId,
  }) async {
    try {
      Logger.info('채팅 메시지 목록 조회 시도: roomId=$roomId');
      final response = await _apiClient.get<List<dynamic>>(
        '/api/chat/rooms/$roomId/messages',
      );

      if (response.data != null) {
        final messages = response.data!
            .map((item) => MessageDto.fromJson(item as Map<String, dynamic>))
            .toList();
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
          final chatRoom = ChatRoomDto.fromJson(response.data!);
          Logger.info('1:1 채팅방 조회/생성 성공: roomId=${chatRoom.roomId}');
          return ApiResult.success(chatRoom);
        } catch (parseError) {
          Logger.error('1:1 채팅방 응답 파싱 실패', error: parseError);
          return ApiResult.failure(UnknownException('채팅방 응답 파싱 중 오류: $parseError'));
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
        final message = MessageDto.fromJson(response.data!);
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







}
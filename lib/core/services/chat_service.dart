// lib/core/services/chat_service.dart

import 'package:dio/dio.dart';
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
      Logger.info('채팅방 생성 시도: chatType=${request.chatType}, participantId=${request.participantId}, referenceId=${request.referenceId}');
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/chat/rooms',
        data: request.toJson(),
      );
      
      Logger.debug('채팅방 생성 원본 응답: ${response.data}');
      
      if (response.data != null) {
        try {
          // 응답 데이터의 각 필드를 개별적으로 체크
          final responseData = response.data!;
          final roomId = responseData['roomId'];
          final roomName = responseData['roomName'];
          final unreadCount = responseData['unreadCount'];
          
          Logger.debug('파싱할 데이터 - roomId: $roomId, roomName: $roomName, unreadCount: $unreadCount');
          
          final chatRoom = ChatRoomResponse.fromJson(responseData);
          Logger.info('채팅방 생성 성공: roomId=${chatRoom.roomId}');
          return ApiResult.success(chatRoom);
        } catch (e) {
          Logger.error('채팅방 응답 파싱 실패', error: e);
          Logger.debug('응답 데이터 타입: ${response.data.runtimeType}');
          Logger.debug('응답 데이터 내용: ${response.data}');
          return ApiResult.failure(UnknownException('채팅방 응답 데이터 파싱에 실패했습니다: ${e.toString()}'));
        }
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

  /// 파일과 함께 메시지 전송
  Future<ApiResult<ChatMessageResponse>> sendMessageWithFile({
    required String roomId,
    required String filePath,
    String? content,
  }) async {
    try {
      Logger.info('파일 메시지 전송 시도: roomId=$roomId, filePath=$filePath');
      
      // FormData 생성을 위해 dio 패키지의 FormData와 MultipartFile 사용
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (content != null && content.isNotEmpty) 'content': content,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/chat/rooms/$roomId/messages/file',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.data != null) {
        final message = ChatMessageResponse.fromJson(response.data!);
        Logger.info('파일 메시지 전송 성공');
        return ApiResult.success(message);
      } else {
        return ApiResult.failure(const UnknownException('파일 메시지 전송 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('파일 메시지 전송 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 채팅방의 메시지를 읽음 처리
  Future<ApiResult<void>> markMessagesAsRead({required String roomId}) async {
    try {
      Logger.info('메시지 읽음 처리 시도: roomId=$roomId');
      
      await _apiClient.patch('/api/chat/rooms/$roomId/read');
      
      Logger.info('메시지 읽음 처리 성공: roomId=$roomId');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('메시지 읽음 처리 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 채팅방 검색
  Future<ApiResult<List<ChatRoomResponse>>> searchChatRooms({
    required String query,
    int page = 0,
    int size = 20,
  }) async {
    try {
      Logger.info('채팅방 검색 시도: query=$query');
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/chat/rooms/search',
        queryParameters: {'query': query, 'page': page, 'size': size},
      );

      if (response.data != null) {
        final List<dynamic> chatRoomsData = response.data!['content'] ?? [];
        final chatRooms = chatRoomsData
            .map((item) => ChatRoomResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        Logger.info('채팅방 검색 성공: ${chatRooms.length}개');
        return ApiResult.success(chatRooms);
      } else {
        return ApiResult.failure(const UnknownException('채팅방 검색 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('채팅방 검색 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 타입별 채팅방 조회
  Future<ApiResult<List<ChatRoomResponse>>> getChatRoomsByType({
    required String chatType,
    int page = 0,
    int size = 20,
  }) async {
    try {
      Logger.info('타입별 채팅방 조회 시도: chatType=$chatType');
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/chat/rooms/types/$chatType',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.data != null) {
        final List<dynamic> chatRoomsData = response.data!['content'] ?? [];
        final chatRooms = chatRoomsData
            .map((item) => ChatRoomResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        Logger.info('타입별 채팅방 조회 성공: ${chatRooms.length}개');
        return ApiResult.success(chatRooms);
      } else {
        return ApiResult.failure(const UnknownException('타입별 채팅방 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('타입별 채팅방 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }
}
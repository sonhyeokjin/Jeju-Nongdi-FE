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

  /// 더미 채팅방 데이터 생성 (테스트용)
  Future<ApiResult<List<ChatRoomView>>> createDummyChatRooms() async {
    try {
      Logger.info('더미 채팅방 데이터 생성 중...');
      
      // 더미 사용자 데이터
      final dummyUsers = [
        UserResponse(
          id: 1,
          name: '감귤농장 김씨',
          email: 'farmer1@jejunongdi.com',
          profileImageUrl: null,
        ),
        UserResponse(
          id: 2,
          name: '일손 박씨',
          email: 'worker1@jejunongdi.com',
          profileImageUrl: null,
        ),
        UserResponse(
          id: 3,
          name: '농업 전문가 이씨',
          email: 'mentor1@jejunongdi.com',
          profileImageUrl: null,
        ),
      ];

      // 더미 채팅방 데이터
      final dummyChatRooms = [
        ChatRoomView(
          roomId: 'dummy-room-1',
          roomName: '감귤 수확 일자리 문의',
          otherUser: dummyUsers[0],
          lastMessage: '안녕하세요! 감귤 수확 일자리에 대해 문의드립니다.',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          unreadCount: 2,
          chatType: 'JOB_POSTING',
        ),
        ChatRoomView(
          roomId: 'dummy-room-2',
          roomName: '농업 기술 상담',
          otherUser: dummyUsers[2],
          lastMessage: '토양 개선에 대한 조언 감사합니다!',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
          chatType: 'MENTORING',
        ),
        ChatRoomView(
          roomId: 'dummy-room-3',
          roomName: '유휴농지 임대 상담',
          otherUser: dummyUsers[1],
          lastMessage: '언제 현장 확인이 가능하신가요?',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
          unreadCount: 1,
          chatType: 'FARMLAND',
        ),
      ];

      Logger.info('더미 채팅방 ${dummyChatRooms.length}개 생성 완료');
      return ApiResult.success(dummyChatRooms);
      
    } catch (e) {
      Logger.error('더미 채팅방 생성 실패', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  /// 더미 메시지 데이터 생성 (테스트용)
  Future<ApiResult<List<MessageDto>>> createDummyMessages(String roomId) async {
    try {
      Logger.info('더미 메시지 데이터 생성 중... roomId: $roomId');

      // 더미 사용자 (나)
      final myUser = UserResponse(
        id: 999,
        name: '나',
        email: 'me@jejunongdi.com',
        profileImageUrl: null,
      );

      // 더미 상대방
      final otherUser = UserResponse(
        id: 1,
        name: '감귤농장 김씨',
        email: 'farmer1@jejunongdi.com',
        profileImageUrl: null,
      );

      // 채팅방별 더미 메시지
      List<MessageDto> messages = [];
      
      switch (roomId) {
        case 'dummy-room-1':
          messages = [
            MessageDto(
              messageId: 'msg-1-1',
              roomId: roomId,
              sender: myUser,
              content: '안녕하세요! 감귤 수확 일자리에 대해 문의드립니다.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-1-2',
              roomId: roomId,
              sender: otherUser,
              content: '안녕하세요! 감귤 수확 일자리에 관심 가져주셔서 감사합니다.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-1-3',
              roomId: roomId,
              sender: otherUser,
              content: '12월 중순부터 1월 말까지 약 한 달 반 정도 일정입니다. 하루 8시간, 일당 12만원으로 생각하고 있어요.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-1-4',
              roomId: roomId,
              sender: myUser,
              content: '조건이 좋네요! 경험은 없는데 괜찮을까요?',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-1-5',
              roomId: roomId,
              sender: otherUser,
              content: '처음이시라도 괜찮습니다. 간단한 교육을 해드릴게요. 언제부터 시작 가능하신가요?',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
              isRead: false,
            ),
          ];
          break;
          
        case 'dummy-room-2':
          final mentorUser = UserResponse(
            id: 3,
            name: '농업 전문가 이씨',
            email: 'mentor1@jejunongdi.com',
            profileImageUrl: null,
          );
          
          messages = [
            MessageDto(
              messageId: 'msg-2-1',
              roomId: roomId,
              sender: myUser,
              content: '안녕하세요! 토양 개선에 대해 조언을 구하고 싶습니다.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(days: 1)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-2-2',
              roomId: roomId,
              sender: mentorUser,
              content: '안녕하세요! 어떤 작물을 기르시는지, 현재 토양 상태는 어떤지 알려주세요.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 20)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-2-3',
              roomId: roomId,
              sender: myUser,
              content: '감귤을 기르고 있는데, 최근 잎이 노랗게 변하고 있어요.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 18)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-2-4',
              roomId: roomId,
              sender: mentorUser,
              content: '질소 부족이나 배수 문제일 가능성이 높습니다. 토양 pH 측정해보시고, 퇴비를 추가로 넣어보세요.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-2-5',
              roomId: roomId,
              sender: myUser,
              content: '조언 감사합니다! 바로 시도해볼게요.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: true,
            ),
          ];
          break;
          
        case 'dummy-room-3':
          final landownerUser = UserResponse(
            id: 2,
            name: '일손 박씨',
            email: 'worker1@jejunongdi.com',
            profileImageUrl: null,
          );
          
          messages = [
            MessageDto(
              messageId: 'msg-3-1',
              roomId: roomId,
              sender: myUser,
              content: '안녕하세요! 올린 유휴농지에 관심이 있습니다.',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 10)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-3-2',
              roomId: roomId,
              sender: landownerUser,
              content: '안녕하세요! 어떤 작물을 기를 계획이신가요?',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 8)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-3-3',
              roomId: roomId,
              sender: myUser,
              content: '채소류를 생각하고 있습니다. 현장 확인이 가능할까요?',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 6)),
              isRead: true,
            ),
            MessageDto(
              messageId: 'msg-3-4',
              roomId: roomId,
              sender: landownerUser,
              content: '언제 현장 확인이 가능하신가요?',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(hours: 5)),
              isRead: false,
            ),
          ];
          break;
          
        default:
          // 기본 메시지
          messages = [
            MessageDto(
              messageId: 'msg-default-1',
              roomId: roomId,
              sender: myUser,
              content: '안녕하세요!',
              messageType: 'TEXT',
              sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
              isRead: true,
            ),
          ];
      }

      Logger.info('더미 메시지 ${messages.length}개 생성 완료');
      return ApiResult.success(messages);
      
    } catch (e) {
      Logger.error('더미 메시지 생성 실패', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }
}
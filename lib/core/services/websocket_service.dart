// lib/core/services/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/core/services/chat_service.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:redux/redux.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

class WebSocketService {
  static WebSocketService? _instance;
  StompClient? _stompClient;
  bool _isConnected = false;
  final StreamController<MessageDto> _messageController = StreamController<MessageDto>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  
  String? _authToken;
  WebSocketConnectionInfo? _wsInfo;
  StompUnsubscribe? _currentRoomSubscription;
  
  // Redux Store 인스턴스
  Store<AppState>? _store;

  static WebSocketService get instance {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }

  WebSocketService._internal();

  /// Redux Store 설정 (앱 초기화 시 호출)
  void setStore(Store<AppState> store) {
    _store = store;
    Logger.info('WebSocketService에 Redux Store 설정 완료');
  }

  /// 현재 로그인한 사용자의 이메일 조회
  String? get currentUserEmail {
    if (_store == null) return null;
    final userState = _store!.state.userState;
    return userState.user?.email;
  }

  Stream<MessageDto> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  /// STOMP WebSocket 연결 초기화
  Future<bool> connect() async {
    try {
      print('🔌 STOMP WebSocket 연결 시도 시작');
      Logger.info('STOMP WebSocket 연결 시도');
      
      // WebSocket 연결 정보 조회
      print('📡 WebSocket 연결 정보 조회 중...');
      final wsInfoResult = await ChatService.instance.getWebSocketInfo();
      print('📡 WebSocket 연결 정보 조회 결과: success=${wsInfoResult.isSuccess}, data=${wsInfoResult.data != null}');
      
      if (!wsInfoResult.isSuccess || wsInfoResult.data == null) {
        print('❌ WebSocket 연결 정보를 가져올 수 없습니다');
        Logger.error('WebSocket 연결 정보를 가져올 수 없습니다.');
        return false;
      }

      _wsInfo = wsInfoResult.data!;
      print('✅ WebSocket 연결 정보 저장 완료: endpoint=${_wsInfo!.endpoint}');
      
      // 인증 토큰 가져오기
      print('🔑 인증 토큰 조회 중...');
      _authToken = await ApiClient.instance.getToken();
      if (_authToken == null) {
        print('❌ 인증 토큰이 없습니다');
        Logger.error('인증 토큰이 없습니다.');
        return false;
      }
      print('✅ 인증 토큰 조회 완료');

      // WebSocket URL 생성
      final baseUrl = EnvironmentConfig.apiBaseUrl;

      final Map<String, String> connectHeaders = {
        'Authorization': 'Bearer $_authToken',
        'Accept-Version': '1.0,1.1,2.0',
        'Heart-Beat': _wsInfo!.sockJsEnabled == true ? '20000,20000' : '10000,10000',
      };

      final Map<String, String> wsHeaders = {
        'Authorization': 'Bearer $_authToken',
      };

      if (_wsInfo!.sockJsEnabled != true) {
        wsHeaders['Sec-WebSocket-Protocol'] = 'v10.stomp, v11.stomp, v12.stomp';
      }

      final StompConfig config;
      if (_wsInfo!.sockJsEnabled == true) {
        final sockJsUrl = baseUrl + (_wsInfo?.endpoint ?? '');
        Logger.info('SockJS URL: $sockJsUrl');
        config = StompConfig.sockJS(
          url: sockJsUrl,
          onConnect: _onConnected,
          onWebSocketError: (error) => Logger.error('WebSocket 오류: $error'),
          onStompError: (error) => Logger.error('STOMP 오류: $error'),
          onDisconnect: _onDisconnected,
          stompConnectHeaders: connectHeaders,
          webSocketConnectHeaders: wsHeaders,
        );
      } else {
        final wsUrl = baseUrl.replaceFirst(RegExp(r'^http'), 'ws') + (_wsInfo?.endpoint ?? '');
        Logger.info('STOMP WebSocket 연결 URL: $wsUrl');
        config = StompConfig(
          url: wsUrl,
          onConnect: _onConnected,
          onWebSocketError: (error) => Logger.error('WebSocket 오류: $error'),
          onStompError: (error) => Logger.error('STOMP 오류: $error'),
          onDisconnect: _onDisconnected,
          stompConnectHeaders: connectHeaders,
          webSocketConnectHeaders: wsHeaders,
        );
      }

      print('🔗 StompClient 생성 및 활성화 시작...');
      _stompClient = StompClient(config: config);

      // 연결 완료를 기다리기 위한 Completer
      final completer = Completer<bool>();
      late StreamSubscription subscription;
      
      // 연결 상태 변경을 감지하기 위한 타이머
      Timer? timeoutTimer;
      
      void checkConnection() {
        if (_isConnected) {
          print('✅ WebSocket 연결 완료 감지');
          completer.complete(true);
          subscription.cancel();
          timeoutTimer?.cancel();
        }
      }
      
      // 주기적으로 연결 상태 확인 (100ms마다)
      subscription = Stream.periodic(const Duration(milliseconds: 100))
          .listen((_) => checkConnection());
      
      // 10초 타임아웃
      timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          print('❌ WebSocket 연결 타임아웃 (10초)');
          completer.complete(false);
          subscription.cancel();
        }
      });
      
      // 연결 시작
      print('🚀 WebSocket 연결 활성화...');
      _stompClient!.activate();
      
      // 연결 완료 대기
      return await completer.future;
    } catch (e) {
      Logger.error('STOMP WebSocket 연결 실패', error: e);
      _isConnected = false;
      _scheduleReconnect();
      return false;
    }
  }

  /// STOMP 연결 성공 콜백
  void _onConnected(StompFrame frame) {
    Logger.info('STOMP WebSocket 연결 성공');
    _isConnected = true;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
  }

  /// STOMP 연결 종료 콜백
  void _onDisconnected(StompFrame frame) {
    Logger.info('STOMP WebSocket 연결 종료');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// 채팅방 구독 및 입장
  Future<bool> joinRoom(String roomId) async {
    print('🔄 joinRoom 시작: roomId=$roomId');
    print('🔄 현재 연결 상태: _isConnected=$_isConnected, _stompClient=${_stompClient != null}, _wsInfo=${_wsInfo != null}');
    
    if (!_isConnected || _stompClient == null || _wsInfo == null) {
      print('❌ WebSocket 연결 상태 불량');
      Logger.error('STOMP WebSocket이 연결되어 있지 않습니다.');
      return false;
    }

    try {
      // 이전 구독 해제
      if (_currentRoomSubscription != null) {
        print('🔄 기존 구독 해제 중...');
        _currentRoomSubscription!();
      }

      // 새 채팅방 구독
      final subscribeDestination = _wsInfo!.subscribePattern?.replaceAll('{roomId}', roomId) ?? '/topic/chat/room/$roomId';
      print('🔔 채팅방 구독 시도: $subscribeDestination');
      Logger.info('채팅방 구독: $subscribeDestination');
      
      _currentRoomSubscription = _stompClient!.subscribe(
        destination: subscribeDestination,
        callback: (frame) {
          try {
            print('📨 STOMP 원시 메시지 수신: ${frame.body}');
            Logger.info('STOMP 메시지 수신: ${frame.body}');
            if (frame.body != null) {
              final messageData = json.decode(frame.body!);
              final message = MessageDto.fromJson(messageData);
              print('📨 메시지 파싱 성공, 스트림에 추가: ${message.id}');
              _messageController.add(message);
            }
          } catch (e) {
            print('❌ STOMP 메시지 파싱 실패: $e');
            Logger.error('STOMP 메시지 파싱 실패', error: e);
          }
        },
      );

      print('✅ 채팅방 구독 완료: $roomId');
      Logger.info('채팅방 입장 성공: $roomId');
      return true;
    } catch (e) {
      print('❌ 채팅방 입장 실패: $e');
      Logger.error('채팅방 입장 실패', error: e);
      return false;
    }
  }

  /// 채팅방 퇴장
  Future<bool> leaveRoom(String roomId) async {
    if (_currentRoomSubscription != null && _stompClient != null) {
      try {
        _currentRoomSubscription!();
        _currentRoomSubscription = null;
        Logger.info('채팅방 퇴장: $roomId');
        return true;
      } catch (e) {
        Logger.error('채팅방 퇴장 실패', error: e);
        return false;
      }
    }
    return true;
  }

  /// 메시지 전송 (Redux에서 사용자 이메일 자동 포함)
  Future<bool> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'TEXT',
  }) async {
    print('🚀 === WebSocket 메시지 전송 시작 ===');
    print('🔌 WebSocket 연결 상태: $_isConnected');
    print('📡 StompClient 상태: ${_stompClient != null}');
    print('⚙️ WebSocket 정보: ${_wsInfo != null}');
    
    if (!_isConnected || _stompClient == null || _wsInfo == null) {
      print('❌ WebSocket 전송 조건 미충족');
      Logger.error('STOMP WebSocket이 연결되어 있지 않습니다.');
      return false;
    }

    try {
      // Redux Store에서 현재 사용자 이메일 조회
      final userEmail = currentUserEmail;
      if (userEmail == null) {
        print('❌ 사용자 이메일을 Redux에서 찾을 수 없습니다');
        Logger.error('사용자 인증 정보가 없습니다.');
        return false;
      }

      // 메시지 데이터에 이메일 포함
      final messageData = {
        'roomId': roomId,
        'content': content,
        'messageType': messageType,
        'email': userEmail, // Redux에서 가져온 이메일 추가
      };

      final destination = _wsInfo!.sendDestination ?? '/app/chat.sendPrivateMessage';
      print('🎯 전송 목적지: $destination');
      print('📦 전송 데이터: $messageData');
      print('👤 발신자 이메일: $userEmail');

      _stompClient!.send(
        destination: destination,
        body: json.encode(messageData),
      );

      print('✅ STOMP 메시지 전송 완료');
      Logger.info('STOMP 메시지 전송: $messageData');
      return true;
    } catch (e) {
      print('❌ STOMP 메시지 전송 실패: $e');
      Logger.error('STOMP 메시지 전송 실패', error: e);
      return false;
    }
  }

  /// 재연결 스케줄링
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      Logger.error('최대 재연결 시도 횟수에 도달했습니다.');
      return;
    }

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (1 << _reconnectAttempts).clamp(1, 30));
    
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      Logger.info('STOMP WebSocket 재연결 시도 $_reconnectAttempts/$_maxReconnectAttempts');
      connect();
    });
  }

  /// 연결 종료
  void disconnect() {
    Logger.info('STOMP WebSocket 연결 종료');
    _isConnected = false;
    _reconnectTimer?.cancel();
    _currentRoomSubscription = null;
    _stompClient?.deactivate();
    _stompClient = null;
  }

  /// 리소스 정리
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
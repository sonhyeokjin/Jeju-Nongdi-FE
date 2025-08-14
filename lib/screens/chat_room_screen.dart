// lib/screens/chat_room_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:jejunongdi/core/services/websocket_service.dart';
import 'package:redux/redux.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final Store<AppState> _store;

  @override
  void initState() {
    super.initState();
    _store = StoreProvider.of<AppState>(context, listen: false);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _store.dispatch(LoadChatMessagesAction(widget.roomId));
      }
    });
  }

  @override
  void dispose() {
    // 채팅방 퇴장 및 연결 해제
    _store.dispatch(LeaveChatRoomAction(widget.roomId));
    _store.dispatch(DisconnectWebSocketAction());
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    print('💬 === 메시지 전송 시작 ===');
    print('💬 UI에서 메시지 전송 시도: "$content"');
    print('🏠 채팅방 ID: ${widget.roomId}');
    
    final request = ChatMessageRequest(content: content);
    _store.dispatch(SendMessageAction(widget.roomId, request));

    _messageController.clear();
    print('💬 === 메시지 전송 UI 작업 완료 ===');

    // 다음 프레임이 렌더링된 후 스크롤을 맨 아래로 이동
    // 위젯 트리가 재구성되는 동안 컨트롤러가 분리될 수 있는 문제를 방지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StoreConnector<AppState, _ViewModel>(
              onInit: (store) async {
                print('🏠 채팅방 화면 초기화: roomId=${widget.roomId}');
                
                // 1. 먼저 WebSocket 연결
                store.dispatch(ConnectWebSocketAction());
                
                // 2. WebSocket 연결 완료를 기다린 후 채팅방 입장
                // 연결 상태를 확인하는 로직 추가
                final webSocketService = WebSocketService.instance;
                int attempts = 0;
                const maxAttempts = 30; // 3초 대기
                
                while (!webSocketService.isConnected && attempts < maxAttempts) {
                  await Future.delayed(const Duration(milliseconds: 100));
                  attempts++;
                }
                
                if (webSocketService.isConnected) {
                  print('✅ WebSocket 연결 완료, 채팅방 입장 시도');
                  print('🚀 JoinChatRoomAction 디스패치 시작: roomId=${widget.roomId}');
                  store.dispatch(JoinChatRoomAction(widget.roomId));
                  print('✅ JoinChatRoomAction 디스패치 완료');
                  
                  // 채팅방 입장 완료를 추가로 기다림
                  await Future.delayed(const Duration(milliseconds: 500));
                  print('🔔 채팅방 입장 처리 완료 대기 완료');
                  
                  // WebSocket 연결 후 메시지 로드
                  store.dispatch(LoadChatMessagesAction(widget.roomId, refresh: true));
                } else {
                  print('❌ WebSocket 연결 실패, HTTP API로 폴백');
                  // WebSocket 연결 실패해도 메시지는 HTTP로 로드
                  store.dispatch(LoadChatMessagesAction(widget.roomId, refresh: true));
                }
              },
              converter: (store) => _ViewModel.fromStore(store, widget.roomId),
              distinct: true,
              builder: (context, vm) {
                if (vm.isLoading && vm.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.error != null) {
                  return Center(child: Text('오류: ${vm.error}'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.messages.length + (vm.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (vm.hasMore && index == vm.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final message = vm.messages[index];
                    // ID로 비교하거나, ID가 없으면 이메일로 비교
                    final isMe = vm.myUserId != null && 
                        (message.senderId.id.toString() == vm.myUserId ||
                         message.email == vm.myEmail);
                    
                    // 디버깅용 로그
                    if (index == 0) { // 최신 메시지에 대해서만 로그 출력
                      print('🔍 메시지 소유권 확인:');
                      print('  - myUserId: ${vm.myUserId} (타입: ${vm.myUserId.runtimeType})');
                      print('  - myEmail: ${vm.myEmail}');
                      print('  - senderId: ${message.senderId.id} (타입: ${message.senderId.id.runtimeType})');
                      print('  - message.email: ${message.email}');
                      print('  - ID 비교 결과: ${message.senderId.id.toString() == vm.myUserId}');
                      print('  - 이메일 비교 결과: ${message.email == vm.myEmail}');
                      print('  - isMe: $isMe');
                      print('  - 메시지 내용: "${message.content}"');
                    }
                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.grey),
              onPressed: () {
                // 파일 전송 기능이 없으므로 비워둡니다.
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: '메시지 보내기', border: InputBorder.none),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFFF2711C),
                  elevation: 2),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageDto message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 50.0 : 0.0,  // 내 메시지는 왼쪽 여백 추가
        right: isMe ? 0.0 : 50.0, // 상대 메시지는 오른쪽 여백 추가
        top: 4.0,
        bottom: 4.0,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFF2711C) : Colors.white, // 전송 버튼과 같은 색상
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), 
                blurRadius: 10, 
                offset: const Offset(0, 2)
              )
            ],
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final List<MessageDto> messages;
  final bool hasMore;
  final String? myUserId;
  final String? myEmail;
  final String? error;

  _ViewModel({
    required this.isLoading, 
    required this.messages, 
    required this.hasMore, 
    this.myUserId,
    this.myEmail,
    this.error,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _ViewModel) return false;
    
    // 메시지 리스트의 내용이 같은지 확인
    if (messages.length != other.messages.length) {
      print('🔍 _ViewModel 비교: 메시지 개수 다름 (${messages.length} vs ${other.messages.length})');
      return false;
    }
    
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].id != other.messages[i].id) {
        print('🔍 _ViewModel 비교: 메시지 ID 다름');
        return false;
      }
    }
    
    final isEqual = isLoading == other.isLoading &&
        hasMore == other.hasMore &&
        myUserId == other.myUserId &&
        myEmail == other.myEmail &&
        error == other.error;
        
    print('🔍 _ViewModel 비교 결과: $isEqual');
    return isEqual;
  }

  @override
  int get hashCode => Object.hash(
    isLoading,
    hasMore,
    myUserId,
    myEmail,
    error,
    messages.map((m) => m.id).join(),
  );

  static _ViewModel fromStore(Store<AppState> store, String roomId) {
    final chatState = store.state.chatState;
    final messages = chatState.messages[roomId] ?? [];
    
    print('🔄 ChatRoomScreen _ViewModel 업데이트: roomId=$roomId, 메시지 개수=${messages.length}');
    if (messages.isNotEmpty) {
      print('📋 최신 메시지: ${messages.first.content}');
    }
    
    final user = store.state.userState.user;
    print('🔍 현재 사용자 정보: id=${user?.id}, email=${user?.email}, name=${user?.name}');
    
    return _ViewModel(
      isLoading: chatState.isLoading,
      messages: List.of(messages), // reducer에서 이미 정렬되므로 추가 정렬 불필요
      hasMore: chatState.hasMoreMessages[roomId] ?? true,
      myUserId: user?.id.toString(), // 실제 ID 사용
      myEmail: user?.email, // 이메일도 함께 저장
      error: chatState.error,
    );
  }
}
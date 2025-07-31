// lib/screens/chat_room_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:jejunongdi/core/services/chat_service.dart';
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

  @override
  void initState() {
    super.initState();
    print('ChatRoomScreen initiated with roomId: ${widget.roomId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Dispatching LoadChatMessagesAction for roomId: ${widget.roomId}');
      final store = StoreProvider.of<AppState>(context, listen: false);
      
      // 더미 룸인 경우 더미 메시지 생성
      if (widget.roomId.startsWith('dummy-room-')) {
        store.dispatch(CreateDummyMessagesAction(widget.roomId));
      } else {
        store.dispatch(LoadChatMessagesAction(widget.roomId, refresh: true));
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // 더미 룸이 아닌 경우에만 추가 메시지 로드
        if (!widget.roomId.startsWith('dummy-room-')) {
          StoreProvider.of<AppState>(context, listen: false)
              .dispatch(LoadChatMessagesAction(widget.roomId));
        }
      }
    });

    // 메시지 로드 후 별도 처리 없음 (새 API에서는 입장/읽음 처리 불필요)
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final store = StoreProvider.of<AppState>(context, listen: false);
    final content = _messageController.text.trim();
    
    // 더미 룸인 경우 더미 메시지로 처리
    if (widget.roomId.startsWith('dummy-room-')) {
      // 더미 메시지 생성 (내가 보낸 메시지)
      final myUser = UserResponse(
        id: 999,
        name: '나',
        email: 'me@jejunongdi.com',
        profileImageUrl: null,
      );
      
      final dummyMessage = MessageDto(
        messageId: 'dummy-msg-${DateTime.now().millisecondsSinceEpoch}',
        roomId: widget.roomId,
        sender: myUser,
        content: content,
        messageType: 'TEXT',
        sentAt: DateTime.now(),
        isRead: false,
      );
      
      store.dispatch(ReceiveMessageAction(dummyMessage));
      
      // 자동 응답 메시지 (3초 후)
      Future.delayed(const Duration(seconds: 3), () {
        final otherUser = UserResponse(
          id: 1,
          name: '감귤농장 김씨',
          email: 'farmer1@jejunongdi.com',
          profileImageUrl: null,
        );
        
        final autoReplyMessage = MessageDto(
          messageId: 'dummy-reply-${DateTime.now().millisecondsSinceEpoch}',
          roomId: widget.roomId,
          sender: otherUser,
          content: '메시지 확인했습니다! 더미 채팅방에서 테스트 중입니다 😊',
          messageType: 'TEXT',
          sentAt: DateTime.now(),
          isRead: false,
        );
        
        if (mounted) {
          store.dispatch(ReceiveMessageAction(autoReplyMessage));
        }
      });
    } else {
      // 실제 API 호출
      final request = ChatMessageRequest(content: content);
      store.dispatch(SendMessageAction(widget.roomId, request));
    }
    
    _messageController.clear();
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
      body: StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.fromStore(store, widget.roomId),
        builder: (context, vm) {
          // 에러 상태일 때 사용자에게 명확한 피드백 제공
          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${vm.error}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      StoreProvider.of<AppState>(context, listen: false)
                          .dispatch(LoadChatMessagesAction(widget.roomId, refresh: true));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2711C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: vm.isLoading && vm.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
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
                    final isMe = vm.myUserId != null && message.sender.id.toString() == vm.myUserId;
                    return _MessageBubble(message: message, isMe: isMe);
                  },
                ),
              ),
              _buildMessageComposer(),
            ],
          );
        },
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
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFF2711C) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
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
  final String? error;

  _ViewModel({
    required this.isLoading, 
    required this.messages, 
    required this.hasMore, 
    this.myUserId,
    this.error,
  });

  static _ViewModel fromStore(Store<AppState> store, String roomId) {
    final chatState = store.state.chatState;
    return _ViewModel(
      isLoading: chatState.isLoading,
      messages: (chatState.messages[roomId] ?? [])..sort((a,b) => b.sentAt.compareTo(a.sentAt)),
      hasMore: chatState.hasMoreMessages[roomId] ?? true,
      myUserId: store.state.userState.user?.id.toString(),
      error: chatState.error,
    );
  }
}
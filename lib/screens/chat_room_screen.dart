// lib/screens/chat_room_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false)
          .dispatch(LoadChatMessagesAction(widget.roomId, refresh: true));
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        StoreProvider.of<AppState>(context, listen: false)
            .dispatch(LoadChatMessagesAction(widget.roomId));
      }
    });

    // 입장 API 호출
    ChatService.instance.enterChatRoom(roomId: widget.roomId);
  }

  @override
  void dispose() {
    // 퇴장 API 호출

    _messageController.dispose();ChatService.instance.leaveChatRoom(roomId: widget.roomId);
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final request = ChatMessageRequest(content: _messageController.text.trim());
    StoreProvider.of<AppState>(context, listen: false)
        .dispatch(SendMessageAction(widget.roomId, request));
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
                    final isMe = message.sender.id.toString() == vm.myUserId;
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
  final ChatMessageResponse message;
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
  final List<ChatMessageResponse> messages;
  final bool hasMore;
  final String? myUserId;

  _ViewModel({required this.isLoading, required this.messages, required this.hasMore, this.myUserId});

  static _ViewModel fromStore(Store<AppState> store, String roomId) {
    final chatState = store.state.chatState;
    return _ViewModel(
      isLoading: chatState.isLoading,
      messages: (chatState.messages[roomId] ?? [])..sort((a,b) => b.sentAt.compareTo(a.sentAt)),
      hasMore: chatState.hasMoreMessages[roomId] ?? true,
      myUserId: store.state.userState.user?.id,
    );
  }
}
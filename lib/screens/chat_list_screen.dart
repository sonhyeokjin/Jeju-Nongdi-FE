// lib/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:jejunongdi/screens/chat_room_screen.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false)
          .dispatch(LoadChatRoomsAction());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '궁시렁',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF2711C),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_comment_outlined),
                          tooltip: '새 대화',
                          color: const Color(0xFFF2711C),
                          onPressed: () {
                            // TODO: 실제로는 사용자 검색 화면으로 이동해야 함
                            // 임시로 사용자 ID 2와 채팅 시작
                            StoreProvider.of<AppState>(context, listen: false)
                                .dispatch(CreateChatRoomAction(2));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: '새로고침',
                          color: const Color(0xFFF2711C),
                          onPressed: () {
                            StoreProvider.of<AppState>(context, listen: false)
                                .dispatch(LoadChatRoomsAction());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 채팅 리스트
            Expanded(
              child: StoreConnector<AppState, _ViewModel>(
                converter: (store) => _ViewModel.fromStore(store),
                builder: (context, vm) {
                  if (vm.isLoading && vm.chatRooms.isEmpty) {
                    return const Center(child: CircularProgressIndicator(
                      color: Color(0xFFF2711C),
                    ));
                  }

                  if (vm.error != null) {
                    return Center(child: Text('오류: ${vm.error}'));
                  }

                  if (vm.chatRooms.isEmpty) {
                    return const Center(
                      child: Text(
                        '대화중인 채팅방이 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100), // 하단 AppBar 공간 확보
                    itemCount: vm.chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = vm.chatRooms[index];
                      return _ChatRoomTile(chatRoom: chatRoom);
                    },
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomResponse chatRoom;

  const _ChatRoomTile({required this.chatRoom});

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dt.year, dt.month, dt.day);

    if (today == messageDate) {
      return DateFormat('a h:mm', 'ko_KR').format(dt);
    } else {
      return DateFormat('M. d.').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFF2711C).withOpacity(0.1),
        backgroundImage: chatRoom.otherUser?.profileImageUrl != null
            ? NetworkImage(chatRoom.otherUser!.profileImageUrl!)
            : null,
        child: chatRoom.otherUser?.profileImageUrl == null
            ? const Icon(Icons.group, color: Color(0xFFF2711C))
            : null,
      ),
      title: Text(
        chatRoom.roomName,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chatRoom.lastMessage ?? '대화를 시작해보세요.',
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: chatRoom.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDateTime(chatRoom.lastMessageTime),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 6),
          if (chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2711C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chatRoom.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          else
            const SizedBox(height: 20),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomId: chatRoom.roomId,
              roomName: chatRoom.roomName,
            ),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final List<ChatRoomResponse> chatRooms;

  _ViewModel({
    required this.isLoading,
    this.error,
    required this.chatRooms,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.chatState.isLoading,
      error: store.state.chatState.error,
      chatRooms: store.state.chatState.chatRooms,
    );
  }
}
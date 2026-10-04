import 'package:flutter/material.dart';
import '../../domain/models/thread.dart';
import 'chat_list_item.dart';

class ChatList extends StatelessWidget {
  final List<Thread> threads;
  final void Function(Thread) onTap;
  const ChatList({Key? key, required this.threads, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: threads.length,
      // remove visible separator line
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final t = threads[index];
        return ChatListItem(thread: t, onTap: () => onTap(t));
      },
    );
  }
}

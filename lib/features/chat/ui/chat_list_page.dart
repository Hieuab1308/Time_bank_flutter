import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'containers/chat_list_container.dart';
import 'chat_conversation_page.dart';
import '../providers/chat_providers.dart';


class ChatListPage extends ConsumerWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Message',  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 0),

              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search member',
                  hintStyle: TextStyle(color: Color(0xFF9AA7B2)),
                  prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF9AA7B2)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                ),
                onChanged: (query) {
                  ref.read(chatSearchQueryProvider.notifier).state = query;
                },
              ),
            ),
          ),
          Expanded(
            child: ChatListContainer(
              onThreadTap: (threadId, threadName) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatConversationPage(
                      threadId: threadId,
                      fallbackName: threadName,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
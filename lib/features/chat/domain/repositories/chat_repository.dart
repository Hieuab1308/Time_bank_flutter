import 'dart:typed_data';
import '../models/message.dart';
import '../models/thread.dart';

abstract class ChatRepository {

  Stream<List<Thread>> watchThreads(String myUid);

  Future<String> ensureDmThread(
      String myUid,
      String peerUid,
      String myName,
      String peerName,
      String myAvatar,
      String peerAvatar,
      );

  Stream<List<Message>> watchMessages(String threadId, {int limit});

  Future<void> sendText({
    required String threadId,
    required String text,
    required String senderId,
    required String localId,
  });

  Future<void> sendImage({
    required String threadId,
    required Uint8List bytes,
    required String senderId,
    required String mime,
    required String localId,
  });

  Future<void> startPresence(String myUid);
  Stream<bool> watchPresence(String uid);
}
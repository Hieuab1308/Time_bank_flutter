import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import '../domain/models/message.dart';
import '../domain/models/thread.dart';
import '../domain/repositories/chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseDatabase? rtdb,
  })  : _fs = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _rtdb = rtdb ?? FirebaseDatabase.instance;

  final FirebaseFirestore _fs;
  final FirebaseStorage _storage;
  final FirebaseDatabase _rtdb;

  @override
  Stream<List<Thread>> watchThreads(String myUid) {
    final q = _fs
        .collection('rooms')
        .where('members', arrayContains: myUid)
        .orderBy('updatedAt', descending: true);

    return q.snapshots().map((snap) {
      return snap.docs.map((doc) {
        try {
          return Thread.fromFirestore(doc);
        } catch (e, st) {
          print('🔥 Lỗi parse Thread ${doc.id}: $e');
          print(st);
          return null;
        }
      }).whereType<Thread>().toList();
    });
  }

  @override
  Future<String> ensureDmThread(
      String myUid,
      String peerUid,
      String myName,
      String peerName,
      String myAvatar,
      String peerAvatar,
      ) async {
    final roomId = ([myUid, peerUid]..sort()).join('_');
    final roomRef = _fs.collection('rooms').doc(roomId);

    await _fs.runTransaction((tx) async {
      final s = await tx.get(roomRef);
      if (!s.exists) {
        tx.set(roomRef, {
          'type': 'dm',
          'members': [myUid, peerUid],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'memberNames': {
            myUid: myName,
            peerUid: peerName,
          },
        });
      }
    });

    return roomId;
  }

  @override
  Stream<List<Message>> watchMessages(String threadId, {int limit = 30}) {
    final q = _fs
        .collection('rooms/$threadId/messages')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    return q.snapshots().map((snap) {
      return snap.docs.map((d) {
        try {
          return Message.fromFirestore(threadId, d);
        } catch (e, st) {
          print('🔥 Lỗi parse Message ${d.id}: $e');
          print(st);
          return null;
        }
      }).whereType<Message>().toList();
    });
  }


  @override
  Future<void> sendText({
    required String threadId,
    required String text,
    required String senderId,
    required String localId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final roomRef = firestore.collection('rooms').doc(threadId);
    final msgRef = roomRef.collection('messages').doc();

    await firestore.runTransaction((tx) async {
      tx.set(msgRef, {
        'threadId': threadId,
        'senderId': senderId,
        'type': 'text',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'localId': localId,
      });
      tx.update(roomRef, {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': {
          'text': text,
          'type': 'text',
          'senderId': senderId,
          'at': FieldValue.serverTimestamp(),
          'localId': localId,
        },
      });
    });
  }

  @override
  Future<void> sendImage({
    required String threadId,
    required Uint8List bytes,
    required String senderId,
    String mime = 'image/jpeg',
    required String localId,
  }) async {
    final path = 'rooms/$threadId/${senderId}_$localId.jpg';
    final ref = _storage.ref().child(path);

    await ref.putData(bytes, SettableMetadata(contentType: mime));
    final url = await ref.getDownloadURL();

    final msgRef = _fs.collection('rooms/$threadId/messages').doc();
    final roomRef = _fs.collection('rooms').doc(threadId);
    await _fs.runTransaction((tx) async {
      tx.set(msgRef, {
        'senderId': senderId,
        'type': 'image',
        'mediaUrl': url,
        'mediaMime': mime,
        'createdAt': FieldValue.serverTimestamp(),
        'localId': localId,
        'readBy': {senderId: FieldValue.serverTimestamp()},
      });
      tx.update(roomRef, {
        'lastMessage': {
          'text': '[image]',
          'type': 'image',
          'senderId': senderId,
          'at': FieldValue.serverTimestamp(),
          'localId': localId,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> startPresence(String myUid) async {
    final ref = _rtdb.ref('status/$myUid');
    await ref.set({
      'online': true,
      'lastActiveAt': ServerValue.timestamp,
      'device': 'flutter',
    });
    ref.onDisconnect().set({
      'online': false,
      'lastActiveAt': ServerValue.timestamp,
      'device': 'flutter',
    });
  }

  @override
  Stream<bool> watchPresence(String uid) {
    return _rtdb.ref('status/$uid/online').onValue.map((e) {
      final v = e.snapshot.value;
      return v == true;
    });
  }
}
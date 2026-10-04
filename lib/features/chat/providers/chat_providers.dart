import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/message.dart';
import '../domain/models/thread.dart';
import '../domain/repositories/chat_repository.dart';
import '../data/firebase_chat_repository.dart';
import '../../auth/providers/auth_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository();
});

final currentUidProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final threadsProvider = StreamProvider<List<Thread>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return repo.watchThreads(uid);
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, threadId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(threadId, limit: 30);
});

final peerProfileProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, peerId) async {
  final api = ref.watch(authedApiClientProvider);

  final res = await api.get('/users/$peerId');

  if (res.statusCode < 200 || res.statusCode >= 300) {
    try {
      final errorBody = json.decode(utf8.decode(res.bodyBytes));
      throw Exception(errorBody['message'] ?? 'Lỗi ${res.statusCode}');
    } catch (e) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  final body = json.decode(utf8.decode(res.bodyBytes));
  return body as Map<String, dynamic>;
});

final myProfileNameProvider = Provider<String>((ref) {
  final myProfileAsync = ref.watch(userProfileProvider);
  return myProfileAsync.when(
    data: (profile) {
      if (profile.fullName != null && profile.fullName!.isNotEmpty) {
        return profile.fullName!;
      }
      return 'Người dùng';
    },
    loading: () => 'Đang tải...',
    error: (e, s) => 'Người dùng',
  );
});

final myProfileAvatarProvider = Provider<String>((ref) {
  final myProfileAsync = ref.watch(userProfileProvider);
  return myProfileAsync.when(
    data: (profile) => profile.avatarUrl ?? '',
    loading: () => '',
    error: (e, s) => '',
  );
});


final ensureDmThreadProvider = FutureProvider.family.autoDispose<String, ({
String peerUid,
String peerName,
String peerAvatar
})>(
      (ref, peerData) async {
    final repo = ref.watch(chatRepositoryProvider);
    final myUid = ref.watch(currentUidProvider);

    if (myUid == null) {
      throw StateError('User must be logged in');
    }

    final myProfile = await ref.read(userProfileProvider.future);
    final myName = (myProfile.fullName != null && myProfile.fullName!.isNotEmpty)
        ? myProfile.fullName!
        : 'Người dùng';
    final myAvatar = myProfile.avatarUrl ?? '';

    return repo.ensureDmThread(
      myUid,
      peerData.peerUid,
      myName,
      peerData.peerName,
      myAvatar,
      peerData.peerAvatar,
    );
  },
);

final sendTextProvider = FutureProvider.family.autoDispose<void, ({
String threadId,
String text,
String localId
})>((ref, args) async {
  final repo = ref.watch(chatRepositoryProvider);
  final myUid = ref.watch(currentUidProvider);
  if (myUid == null) throw StateError('User must be logged in');
  await repo.sendText(
    threadId: args.threadId,
    text: args.text,
    senderId: myUid,
    localId: args.localId,
  );
});

final sendImageProvider = FutureProvider.family.autoDispose<void, ({
String threadId,
Uint8List bytes,
String mime,
String localId
})>((ref, args) async {
  final myUid = ref.watch(currentUidProvider);
  if (myUid == null) throw StateError('User must be logged in');

  final firestore = FirebaseFirestore.instance;
  final storage = fs.FirebaseStorage.instance;
  final path = 'chat_images/${args.threadId}/$myUid/${args.localId}.jpg';
  final task = await storage.ref(path).putData(args.bytes, fs.SettableMetadata(contentType: args.mime));
  final url = await task.ref.getDownloadURL();
  final roomRef = firestore.collection('rooms').doc(args.threadId);
  final msgRef = roomRef.collection('messages').doc();

  await firestore.runTransaction((tx) async {
    tx.set(msgRef, {
      'threadId': args.threadId,
      'senderId': myUid,
      'type': 'image',
      'mediaUrl': url,
      'mediaMime': args.mime,
      'createdAt': FieldValue.serverTimestamp(),
      'localId': args.localId,
    });
    tx.update(roomRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': {
        'text': '[image]',
        'type': 'image',
        'senderId': myUid,
        'at': FieldValue.serverTimestamp(),
        'localId': args.localId,
      },
    });
  });
});


final startPresenceProvider = Provider<void>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return;
  final db = FirebaseDatabase.instance;
  final userRef = db.ref('status/$uid');
  final connectedRef = db.ref('.info/connected');
  userRef.onDisconnect().set({
    'state': 'offline',
    'last_changed': ServerValue.timestamp,
  });
  connectedRef.onValue.listen((event) {
    final connected = event.snapshot.value == true;
    if (connected) {
      userRef.set({
        'state': 'online',
        'last_changed': ServerValue.timestamp,
      });
    }
  });
});

final presenceProvider = StreamProvider.family<bool, String>((ref, uid) {
  final db = FirebaseDatabase.instance;
  return db.ref('status/$uid/state').onValue.map(
        (e) => e.snapshot.value == 'online',
  );
});

final chatSearchQueryProvider = StateProvider<String>((_) => '');
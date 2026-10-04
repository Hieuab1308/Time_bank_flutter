import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }

enum MessageStatus { pending, sent, failed }

class Message {
  final String id;
  final String threadId;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final String? mediaMime;
  final DateTime createdAt;


  final String? localId;    // ID tạm thời
  final MessageStatus status; // Trạng thái của tin nhắn
  final bool isLocalFile;  // True nếu mediaUrl là đường dẫn file local (cho ảnh đang upload)

  const Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
    this.mediaMime,
    required this.createdAt,

    this.localId,
    this.status = MessageStatus.sent, // Mặc định là 'sent'
    this.isLocalFile = false,       // Mặc định là 'false'
  });

  factory Message.fromFirestore(String threadId, DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Message(
      id: doc.id,
      threadId: threadId,
      senderId: d['senderId'] as String? ?? '',
      type: (d['type'] == 'image') ? MessageType.image : MessageType.text,
      text: d['text'] as String?,
      mediaUrl: d['mediaUrl'] as String?,
      mediaMime: d['mediaMime'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),


      localId: d['localId'] as String?,

      status: MessageStatus.sent,
      isLocalFile: false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'type': type == MessageType.image ? 'image' : 'text',
    if (text != null) 'text': text,
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
    if (mediaMime != null) 'mediaMime': mediaMime,
    'createdAt': FieldValue.serverTimestamp(),

    if (localId != null) 'localId': localId,
  };

  Message copyWith({
    String? id,
    String? threadId,
    String? senderId,
    MessageType? type,
    String? text,
    String? mediaUrl,
    String? mediaMime,
    DateTime? createdAt,
    String? localId,
    MessageStatus? status,
    bool? isLocalFile,
  }) {
    return Message(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaMime: mediaMime ?? this.mediaMime,
      createdAt: createdAt ?? this.createdAt,
      localId: localId ?? this.localId,
      status: status ?? this.status,
      isLocalFile: isLocalFile ?? this.isLocalFile,
    );
  }
}
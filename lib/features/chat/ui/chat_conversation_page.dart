import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'containers/conversation_container.dart';
import '../providers/chat_providers.dart';

class ChatConversationPage extends ConsumerWidget {
	final String threadId;
	final String fallbackName;

	const ChatConversationPage({
		Key? key,
		required this.threadId,
		required this.fallbackName,
	}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final myUid = ref.watch(currentUidProvider);
		if (myUid == null) {
			return const Scaffold(body: Center(child: CircularProgressIndicator()));
		}

		String? peerUid;
		if (threadId.contains('_')) {
			try {
				final members = threadId.split('_');
				peerUid = members.firstWhere((uid) => uid != myUid);
			} catch (e) {
				peerUid = null;
			}
		}

		final peerProfileAsync = (peerUid != null)
				? ref.watch(peerProfileProvider(peerUid))
				: const AsyncValue.data(<String, dynamic>{});

		final presenceAsync = (peerUid != null)
				? ref.watch(presenceProvider(peerUid))
				: const AsyncValue<bool>.data(false);
		final isPeerOnline = presenceAsync.asData?.value ?? false;

		String currentTitle;
		String? peerAvatarUrl;
		String initials;

		if (peerUid != null && peerProfileAsync.hasValue && peerProfileAsync.value != null) {
			final peerData = peerProfileAsync.value!;
			currentTitle = peerData['full_name'] as String? ?? fallbackName;
			peerAvatarUrl = peerData['avatar_url'] as String?;
			initials = currentTitle.isNotEmpty ? currentTitle[0].toUpperCase() : '?';
		} else {
			currentTitle = fallbackName;
			initials = currentTitle.isNotEmpty ? currentTitle[0].toUpperCase() : '?';
		}


		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.white,
				foregroundColor: Colors.black,
				elevation: 0,
				titleSpacing: 0,
				title: Row(
					children: [
						// Avatar
						SizedBox(
							width: 44,
							height: 44,
							child: Stack(
								clipBehavior: Clip.none,
								children: [
									Positioned.fill(
										child: CircleAvatar(
											radius: 20,
											backgroundColor: const Color(0xFFE9EEF2),
											backgroundImage: (peerAvatarUrl != null && peerAvatarUrl.isNotEmpty)
													? NetworkImage(peerAvatarUrl)
													: null,
											child: (peerAvatarUrl == null || peerAvatarUrl.isEmpty)
													? Text(
												initials,
												style: const TextStyle(
													fontWeight: FontWeight.w700,
													fontSize: 16,
													color: Color(0xFF334155),
												),
											)
													: null,
										),
									),
									if (peerUid != null)
										Positioned(
											right: 0,
											bottom: 0,
											child: Transform.translate(
												offset: const Offset(2, 0),
												child: Container(
													width: 14,
													height: 14,
													decoration: BoxDecoration(
														color: isPeerOnline ? Colors.green : Colors.grey.shade600,
														shape: BoxShape.circle,
														border: Border.all(color: Colors.white, width: 2.5),
													),
												),
											),
										),
								],
							),
						),
						const SizedBox(width: 12),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(currentTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
								if (peerUid != null)
									Text(
										isPeerOnline ? 'Online' : 'Offline',
										style: TextStyle(fontSize: 12, color: isPeerOnline ? Colors.green : const Color(0xFF6B7B88)),
									),
							],
						),
					],
				),
			),
			body: ConversationContainer(
				threadId: threadId,
				fallbackName: fallbackName,
				peerAvatarUrl: peerAvatarUrl,
				peerInitials: initials,
			),
		);
	}
}
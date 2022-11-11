import 'package:flutter/material.dart';
import 'package:reach_auth/providers/providers.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatListTile extends ConsumerWidget {
  final Chat chat;

  const ChatListTile({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final currentUserId = ref.watch(userIdPvdr);
    bool isCurrentUserSentLastMessage = currentUserId == chat.lastMessage.fromId;
    //TODO: PRESETNER
    String chatTitle = "";

    int? chatColor = 0;

    bool isLastMessageSeen = chat.isLastMessageSeenByUser(currentUserId);

    String imageUrl = "";

    if (chat is GroupChat) {
      final GroupChat groupChat = chat as GroupChat;
      chatTitle = groupChat.groupName;
      chatColor = groupChat.color;
    } else if (chat is PeerChat) {
      final PeerChat peerChat = chat as PeerChat;
      if (currentUserId == peerChat.researcher.researcherId) {
        chatColor = peerChat.participant.defaultColor;
        chatTitle = peerChat.participant.name;
        imageUrl = peerChat.participant.imageUrl;
      } else {
        chatColor = peerChat.researcher.defaultColor;
        chatTitle = peerChat.researcher.name;
        imageUrl = peerChat.researcher.imageUrl;
      }
    }

    final content = ref.watch(contentState(chat.lastMessage.content));

    return GestureDetector(
      onTap: () {
        ref.read(openedChatPvdr.notifier).state = chat;
        Get.to(() => const ChatScreen());
      },
      child: Container(
        height: 75,
        color: isLastMessageSeen ? Colors.white : Colors.blue[50]!,
        child: Row(
          children: [
            sizedWidth8,
            if (imageUrl.isEmpty)
              LetterAvatar(
                color: chatColor,
                title: chatTitle,
                dimension: 60,
              )
            else
              Avatar(
                dimension: 60,
                link: imageUrl,
              ),
            Expanded(
              child: Padding(
                padding: padding8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chatTitle,
                          style: titleSmallBold,
                        ),
                        Text(
                          Formatter.formatSinceLastMessage(
                            chat.lastMessage.timeStamp,
                          ),
                          style: descMed,
                        ),
                      ],
                    ),
                    Text(
                      isCurrentUserSentLastMessage ? "${"you".tr}: $content" : content,
                      overflow: TextOverflow.clip,
                      style: descMed,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final contentState = StateProvider.autoDispose.family<dynamic, String>((ref, lastMessage) {
  if (lastMessage.length > 80) return "${lastMessage.substring(0, 80)}...";
  if (lastMessage.contains("\n")) return lastMessage.replaceAll("\n", " ");
  return lastMessage;
});

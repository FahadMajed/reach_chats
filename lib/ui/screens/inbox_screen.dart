import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

final chatsInboxScaffold = GlobalKey<ScaffoldState>();

class ChatsInboxScreen extends ConsumerWidget {
  final bool withAnnouncements;
  final Function()? onIconPress;
  final Filter? filter;

  const ChatsInboxScreen({
    Key? key,
    this.withAnnouncements = false,
    this.onIconPress,
    this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final chatsListAsync = ref.watch(chatsPvdr);

    return Scaffold(
      key: chatsInboxScaffold,
      appBar: AppBar(
        title: Text("chats".tr),
        actions: [
          if (withAnnouncements)
            IconButton(
              onPressed: onIconPress,
              icon: const FaIcon(
                FontAwesomeIcons.bullhorn,
                size: iconSize16,
              ),
            )
        ],
      ),
      body: chatsListAsync.when(
        data: (chatsList) {
          chatsList = chatsList.where(filter ?? (c) => true).toList();

          return chatsList.isNotEmpty
              ? ListView.builder(
                  itemCount: chatsList.length,
                  itemBuilder: (context, index) {
                    final chat = chatsList[index];
                    bool isYou = chat.researcher.researcherId ==
                        chat.lastMessageSenderId;

                    String chatTitle = "";

                    int? chatColor = 0;

                    bool isLastMessageSeen = false;

                    String imageUrl = "";

                    if (chat is GroupChat) {
                      final GroupChat groupChat = chat;
                      chatTitle = groupChat.groupName;
                      chatColor = groupChat.color;
                      //TODO FIX IS LAST MESSAGE SEEN
                      isLastMessageSeen = true;
                    } else if (chat is PeerChat) {
                      final PeerChat peerChat = chat;
                      chatColor = peerChat.participant.defaultColor;
                      chatTitle = peerChat.participant.name;
                      imageUrl = peerChat.participant.imageUrl;
                      isLastMessageSeen = true;
                    }

                    return Column(
                      children: [
                        ChatListTile(
                            onTap: () => Get.to(ChatScreen(chat)),
                            color: isLastMessageSeen
                                ? Colors.white
                                : Colors.blue[50]!,
                            chatColor: chatColor,
                            isYou: isYou,
                            chatTitle: chatTitle,
                            lastMessage: chat.lastMessage,
                            imageUrl: imageUrl,
                            lastMessageDate: chat.lastMessageDate),
                        const Divider(
                          height: 0,
                          thickness: 0.5,
                        ),
                      ],
                    );
                  },
                )
              : EmptyIndicator("no_chats_yet".tr);
        },
        error: (e, t) => ErrorWidget(e),
        loading: () => const Loading(),
      ),
    );
  }
}

typedef Filter = bool Function(Chat chat);

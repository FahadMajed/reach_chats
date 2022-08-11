import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    List<Chat> chatsList = ref.watch(chatsPvdr);
    chatsList = chatsList.where(filter ?? (c) => true).toList();
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
        body: chatsList.isNotEmpty
            ? ListView.builder(
                itemCount: chatsList.length,
                itemBuilder: (context, index) {
                  final chat = chatsList[index];
                  bool isYou =
                      chat.researcher.researcherId == chat.lastMessageSenderId;

                  String chatTitle = "";

                  int? chatColor = 0;

                  bool isLastMessageSeen = false;

                  String imageUrl = "";

                  if (chat is GroupChat) {
                    final GroupChat groupChat = chat;
                    chatTitle = groupChat.groupName;
                    chatColor = groupChat.color;
                    if (groupChat.isLastMessageSeen == 1) {
                      isLastMessageSeen = true;
                    }
                  } else if (chat is PeerChat) {
                    final PeerChat peerChat = chat;
                    chatColor = peerChat.participant.defaultColor;
                    chatTitle = peerChat.participant.name;
                    imageUrl = peerChat.participant.imageUrl;
                    if (peerChat.isLastMessageSeen == 1) {
                      isLastMessageSeen = true;
                    }
                  }

                  return Column(
                    children: [
                      ChatListTile(
                          onTap: () => Get.to(ChatScreen(chat)),
                          color: isLastMessageSeen
                              ? Colors.white
                              : Colors.blue[50]!,
                          chatColor: chatColor!,
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
            : EmptyIndicator("no_chats_yet".tr));
  }
}

typedef Filter = bool Function(Chat chat);

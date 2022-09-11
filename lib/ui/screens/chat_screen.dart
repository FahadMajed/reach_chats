import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';
import 'package:reach_research/research/providers/providers.dart';


import 'chat_info_screen.dart';

class ChatScreen extends ConsumerWidget {
  final Chat chat;

  ChatScreen(this.chat, {Key? key}) : super(key: key);

  final FocusNode bodyFocusNode = FocusNode();

  @override
  Widget build(BuildContext context, ref) {
    final read = ref.read;

    final bool isGroupChat = chat is GroupChat;
    final appBarText = isGroupChat
        ? (chat as GroupChat).groupName
        : (chat as PeerChat).researcher.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
        actions: [
          IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                if (isGroupChat && read(isResearcherPvdr)) {
                  Get.to(ChatInfoScreen(
                    chat: chat as GroupChat,
                  ));
                }
              },
              icon: LetterAvatar(
                  dimension: 35,
                  color: chat.color,
                  title: appBarText.substring(0, 1)))
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(bodyFocusNode),
        child: Column(
          children: [
            Expanded(
              child: ChatScreenBody(chat),
            ),
            ChatScreenBottomBar(
              chat: chat,
            ),
          ],
        ),
      ),
    );
  }
}

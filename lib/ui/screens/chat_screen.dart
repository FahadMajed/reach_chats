import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';

class ChatScreen extends StatelessWidget {
  final Chat chat;

  ChatScreen(this.chat, {Key? key}) : super(key: key);

  final FocusNode bodyFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final bool isGroupChat = chat is GroupChat;
    final appBarText = isGroupChat
        ? (chat as GroupChat).groupName
        : (chat as PeerChat).researcher.name;

    return Scaffold(
      appBar: AppBar(title: Text(appBarText)),
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

// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:reach_auth/reach_auth.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatScreenBottomBar extends ConsumerStatefulWidget {
  final Chat chat;

  const ChatScreenBottomBar({Key? key, required this.chat}) : super(key: key);

  @override
  ConsumerState<ChatScreenBottomBar> createState() =>
      _ChatScreenBottomBarState(chat);
}

class _ChatScreenBottomBarState extends ConsumerState<ChatScreenBottomBar> {
  final Chat chat;

  _ChatScreenBottomBarState(this.chat);

  final _controller = TextEditingController();
  String content = "";
  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(userPvdr).value?.uid;

    return Container(
      color: Colors.white,
      height: 86,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMessageTextField(),
            _buildSendIconButton(ref.read, currentUserId!),
          ],
        ),
      ),
    );
  }

  _buildMessageTextField() => Expanded(
        child: TextField(
          maxLines: 30,
          minLines: 1,
          textInputAction: TextInputAction.newline,
          decoration: messageTextFieldDecoration,
          controller: _controller,
          onChanged: (messageContent) =>
              setState(() => content = messageContent),
        ),
      );

  IconButton _buildSendIconButton(Reader read, String currentUserId) =>
      IconButton(
        padding: const EdgeInsets.all(0),
        icon: const Icon(Icons.arrow_circle_up),
        iconSize: 30,
        color: Colors.blue,
        onPressed: content.trim().isEmpty
            ? null
            : () {
                final chatsNotifier = read(chatsPvdr.notifier);
                //send message

                if (content.isNotEmpty) {
                  _controller.clear();

                  final messageId = Formatter.formatTimeId();

                  Message newMessage = Message(
                    messageId: messageId,
                    fromId: currentUserId,
                    toId: "all",
                    content: content,
                    timeStamp: Timestamp.now(),
                  );

                  if (chat is GroupChat) {
                    chatsNotifier.sendMessage(chat.chatId, newMessage);
                  } else if (chat is PeerChat) {
                    chatsNotifier.sendMessage(
                      chat.chatId,
                      newMessage.copyWith(
                          toId: (chat as PeerChat).researcher.researcherId),
                    );
                  }

                  //update
                  chatsNotifier.updateChat(
                    copyChatWith(
                      chat,
                      lastMessageSenderId: newMessage.fromId,
                      lastMessage: newMessage.content,
                      lastMessageDate: newMessage.timeStamp,
                      dateOpenedByMembers: {
                        ...chat.dateOpenedByMembers,
                        currentUserId: Timestamp.now()
                      },
                    ),
                  );
                }

                content = "";
              },
      );
}

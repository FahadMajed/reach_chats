import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:reach_auth/reach_auth.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatScreenBody extends ConsumerStatefulWidget {
  final Chat chat;

  const ChatScreenBody(
    this.chat, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreenBody> createState() => _ChatScreenBodyState(chat);
}

class _ChatScreenBodyState extends ConsumerState<ChatScreenBody> {
  final Chat chat;

  late Message? lastMessage;

  //MAKE IT FROM NOTIFIER
  late ChatsRepository chatsRepo;
  String? currentUserId = "";

  _ChatScreenBodyState(this.chat);

  @override
  Widget build(BuildContext context) {
    final watch = ref.watch;
    chatsRepo = watch(chatsRepoPvdr);
    currentUserId = watch(userPvdr).value?.uid;

    final messagesValue = watch(messagesStreamPvdr(widget.chat.chatId));
    Widget sortMessages() {
      List<Message> messages = [];
      //FIREBASE: The caller does not have permission to execute the specified operation.
      messagesValue.whenData((m) => messages = m);
      // it is decending from db
      try {
        List<Widget> messagesTimeline = [];
        if (messages.isNotEmpty) {
          lastMessage = messages.first;
        }

        for (Message m in messages) {
          // loop starts from newest to oldest
          DateTime currentMessageDate = m.timeStamp.toDate();

          DateTime nextMessageDate;

          bool areSameDayAndMonth = false;

          if (m != messages.last) {
            int currentMessageIndex = messages.indexOf(m);

            int nextMessageIndex = currentMessageIndex + 1;

            nextMessageDate = messages[nextMessageIndex].timeStamp.toDate();

            if (currentMessageDate.day == nextMessageDate.day &&
                currentMessageDate.month == nextMessageDate.month) {
              areSameDayAndMonth = true;
            }
          }

          messagesTimeline.add(
            MessageBubble(
              message: m,
              chat: chat,
            ),
          );
          //first message, so its date must show

          if (m == messages.last) {
            messagesTimeline.add(DateInfo(date: currentMessageDate));
          } else if (areSameDayAndMonth == false) {
            messagesTimeline.add(DateInfo(date: currentMessageDate));
          }
        }

        return MediaQuery.removePadding(
          removeBottom: true,
          context: context,
          child: ListView(
            reverse: true,
            children: messagesTimeline,
          ),
        );
      } catch (e) {
 
        return Text(
          "something_went_wrong".tr,
          style: titleSmall,
        );
      }
    }

    return sortMessages();
  }

  @override
  void dispose() {
    //in case there is a message

    if (lastMessage != null) {
      chatsRepo.updateDocument(
        copyChatWith(
          chat,
          lastMessageSenderId: lastMessage!.fromId,
          lastMessage: lastMessage!.content,
          lastMessageDate: lastMessage!.timeStamp,
          dateOpenedByMembers: {
            ...chat.dateOpenedByMembers,
            currentUserId!: Timestamp.now()
          },
        ),
      );
    }
    // case no messages, we want to update date opened only
    else {
      chatsRepo.updateDocument(
        copyChatWith(
          chat,
          dateOpenedByMembers: {
            ...chat.dateOpenedByMembers,
            currentUserId!: Timestamp.now()
          },
        ),
      );
    }

    super.dispose();
  }
}

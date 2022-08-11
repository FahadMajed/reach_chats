import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:reach_auth/reach_auth.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class MessageBubble extends ConsumerWidget {
  final Message message;
  final Chat chat;

  const MessageBubble({Key? key, required this.message, required this.chat})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final currentUserId = ref.watch(userPvdr).value?.uid;

    return currentUserId == message.fromId
        ? MyMessageBubble(
            message: message,
          )
        : PeerMessageBubble(
            peerName: getPeerName(),
            message: message,
          );
  }

  String getPeerName() {
    if (chat is GroupChat) {
      if (chat.lastMessageSenderId == chat.researcher.researcherId) {
        return chat.researcher.name;
      } else if (chat.researcher.researcherId == message.fromId) {
        return chat.researcher.name;
      } else {
        return (chat as GroupChat)
            .participants
            .firstWhere((p) => p.participantId == message.fromId)
            .name;
      }
    }
    return "";
  }
}

class DateInfo extends StatelessWidget {
  const DateInfo({
    Key? key,
    required this.date,
  }) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final dateToString = date.toString().substring(0, 10);
    return Container(
      child: Center(
        child: Padding(
          padding: padding8,
          child: Text(
              DateTime.now().toString().contains(dateToString)
                  ? "today".tr
                  : Formatter.parseDateNoTime(dateToString),
              style: titleSmallBold),
        ),
      ),
    );
  }
}

class MyMessageBubble extends StatelessWidget {
  final Message message;

  const MyMessageBubble({Key? key, required this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(
        padding: TranslationService.isEnglish()
            ? myMessageOutterPadding
            : peerMessagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: messageInnerPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius.copyWith(
                    topRight: TranslationService.isEnglish()
                        ? Radius.zero
                        : radius.topRight,
                    topLeft: TranslationService.isEnglish()
                        ? radius.topLeft
                        : Radius.zero),
              ),
              child: Flex(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                direction: Axis.vertical,
                children: [
                  Flexible(
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: MediaQuery.of(context).textScaleFactor * 14,
                      ),
                    ),
                  ),
                  //message date
                  Text(
                    Formatter.formatSentAt(message.timeStamp),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: MediaQuery.of(context).textScaleFactor * 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class PeerMessageBubble extends StatelessWidget {
  final Message message;
  final String peerName;

  const PeerMessageBubble({
    Key? key,
    required this.peerName,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: TranslationService.isEnglish()
            ? peerMessagePadding
            : myMessageOutterPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (peerName.isNotEmpty)
              Text(
                peerName,
                style: titleSmall,
              ),
            Container(
              padding: messageInnerPadding,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: radius.copyWith(
                    topRight: TranslationService.isEnglish()
                        ? radius.topRight
                        : Radius.zero,
                    topLeft: TranslationService.isEnglish()
                        ? Radius.zero
                        : radius.topLeft),
              ),
              child: Flex(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                direction: Axis.vertical,
                children: [
                  //message
                  Text(
                    message.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).textScaleFactor * 14,
                    ),
                  ),
                  //message date
                  Text(
                    Formatter.formatSentAt(message.timeStamp),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: MediaQuery.of(context).textScaleFactor * 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

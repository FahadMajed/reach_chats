import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class PeerMessageBubble extends StatelessWidget {
  final MessageViewModel messageViewModel;

  const PeerMessageBubble({
    Key? key,
    required this.messageViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: TranslationService.isEnglish() ? peerMessagePadding : myMessageOutterPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (messageViewModel.senderName.isNotEmpty)
              Text(
                messageViewModel.senderName,
                style: titleSmall,
              ),
            Container(
              padding: messageInnerPadding,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: radius.copyWith(
                    topRight: TranslationService.isEnglish() ? radius.topRight : Radius.zero,
                    topLeft: TranslationService.isEnglish() ? Radius.zero : radius.topLeft),
              ),
              child: Flex(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                direction: Axis.vertical,
                children: [
                  //message
                  Text(
                    messageViewModel.message.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).textScaleFactor * 14,
                    ),
                  ),
                  //message date
                  Text(
                    messageViewModel.sentAt,
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

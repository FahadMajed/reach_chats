import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class MyMessageBubble extends StatelessWidget {
  final MessageViewModel messageViewModel;

  const MyMessageBubble({Key? key, required this.messageViewModel})
      : super(key: key);
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
                      messageViewModel.message.content,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: MediaQuery.of(context).textScaleFactor * 14,
                      ),
                    ),
                  ),
                  //message date
                  Text(
                    messageViewModel.sentAt,
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

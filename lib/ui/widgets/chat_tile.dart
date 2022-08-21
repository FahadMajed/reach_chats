import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:reach_core/core/core.dart';

class ChatListTile extends ConsumerWidget {
  final String chatTitle;
  final String lastMessage;
  final int chatColor;
  final Timestamp lastMessageDate;
  final Color color;
  final Function() onTap;
  final bool isYou;
  final String imageUrl;

  const ChatListTile(
      {Key? key,
      required this.color,
      required this.chatTitle,
      required this.chatColor,
      required this.lastMessage,
      required this.lastMessageDate,
      required this.onTap,
      required this.imageUrl,
      required this.isYou})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final content = ref.watch(contentState(lastMessage));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        color: color,
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
                          Formatter.formatSinceLastMessage(lastMessageDate),
                          style: descMed,
                        ),
                      ],
                    ),
                    Text(
                      isYou ? "${"you".tr}: $content" : content,
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

final contentState =
    StateProvider.autoDispose.family<dynamic, String>((ref, lastMessage) {
  if (lastMessage.length > 80) return "${lastMessage.substring(0, 80)}...";
  if (lastMessage.contains("\n")) return lastMessage.replaceAll("\n", " ");
  return lastMessage;
});

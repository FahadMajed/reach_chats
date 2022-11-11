import 'package:flutter/material.dart';

import 'package:reach_chats/chats.dart';
import 'package:reach_core/lib.dart';

class ChatInfoScreen extends StatelessWidget {
  final GroupChat chat;
  final Widget child;
  const ChatInfoScreen({
    Key? key,
    required this.chat,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReachScaffold(
      title: "Info",
      withWhiteContainer: false,
      body: [child],
    );
  }
}

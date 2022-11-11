import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatScreenAppBar extends StatelessWidget with PreferredSizeWidget {
  const ChatScreenAppBar({
    Key? key,
    required this.viewCtrl,
    required this.chatViewModel,
  }) : super(key: key);

  final ChatViewController viewCtrl;
  final ChatViewModel chatViewModel;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(chatViewModel.appBarText),
      actions: [
        IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: viewCtrl.onPeerImagePressed,
            icon: chatViewModel.hasAvatar
                ? Avatar(
                    link: chatViewModel.imageUrl,
                  )
                : LetterAvatar(
                    dimension: 35,
                    color: chatViewModel.peerImageColor,
                    title: chatViewModel.textOnAvatar,
                  ))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

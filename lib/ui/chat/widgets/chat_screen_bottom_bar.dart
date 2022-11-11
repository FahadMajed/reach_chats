// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';

class ChatScreenBottomBar extends StatelessWidget {
  final ChatViewController viewController;

  const ChatScreenBottomBar(
    this.viewController, {
    super.key,
  });

  @override
  Widget build(_) {
    return Container(
      color: Colors.white,
      height: 86,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMessageTextField(viewController.msgFieldCtrl),
            _buildSendIconButton(onPressed: viewController.onSend),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTextField(TextEditingController fieldCtrl) => Expanded(
        child: TextField(
          maxLines: 30,
          minLines: 1,
          textInputAction: TextInputAction.newline,
          decoration: messageTextFieldDecoration,
          controller: fieldCtrl,
        ),
      );

  IconButton _buildSendIconButton({required void Function()? onPressed}) => IconButton(
        padding: const EdgeInsets.all(0),
        icon: const Icon(Icons.arrow_circle_up),
        iconSize: 30,
        color: Colors.blue,
        onPressed: onPressed,
      );
}

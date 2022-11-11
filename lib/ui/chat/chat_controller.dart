import 'package:flutter/material.dart';
import 'package:reach_auth/providers/providers.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatViewController extends AsyncViewController<ChatViewModel> {
  final msgFieldCtrl = TextEditingController();

  late final SendMessage _sendMessage;
  late final UpdateChatDateOpened _updateDateOpened;

  late final String userId;

  ChatViewController(super.read) : super(viewModelPvdr: chatViewModelPvdr) {
    _sendMessage = read(sendMessagePvdr);
    _updateDateOpened = read(updateChatDateOpenedPvdr);
    userId = read(userIdPvdr);
  }

  Chat get chat => chatsStateCtrl.getChat(chatId)!;

  String get chatId => read(openedChatPvdr).chatId;

  Future<void> onSend() async {
    final content = msgFieldCtrl.text;
    if (content.trim().isEmpty) {
    } else {
      //send message

      _callSendMessage();
      msgFieldCtrl.clear();
    }
  }

  Future<void> _callSendMessage() async {
    _sendMessage.call(
      SendMessageRequest(
        fromId: userId,
        content: msgFieldCtrl.text,
        chat: chat,
      ),
    );
  }

  Future<void> _callUpdateDateOpened() async {
    _updateDateOpened.call(
      UpdateChatDateOpenedRequest(
        userId: userId,
        chatId: chatId,
      ),
    );
  }

  void onPeerImagePressed() {
    if (chat.isGroupChat) {}
  }

  @override
  void didPop() {
    _callUpdateDateOpened();
    super.didPop();
  }

  @override
  void didPush() {
    _callUpdateDateOpened();
    super.didPop();
  }
}

final chatViewCtrlPvdr = Provider.autoDispose((ref) => ChatViewController(ref.read));

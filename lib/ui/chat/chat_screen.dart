// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class _ChatScreen extends ViewState<ChatScreen, AsyncValue<ChatViewModel>, ChatViewController> {
  _ChatScreen(super.viewModelProvider, super.viewControllerProvider);

  final bodyFocusNode = FocusNode();
  @override
  Widget buildView() {
    return viewModel.when(
        data: (chatViewModel) => Scaffold(
              appBar: ChatScreenAppBar(
                viewCtrl: viewController,
                chatViewModel: chatViewModel,
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(bodyFocusNode),
                child: Column(
                  children: [
                    MessagesListView(chatViewModel.elements),
                    ChatScreenBottomBar(viewController),
                  ],
                ),
              ),
            ),
        error: (e, _) => ErrorScaffold(e),
        loading: () => const LoadingScaffold());
  }
}

class ChatScreen extends View {
  const ChatScreen({Key? key})
      : super(
          key: key,
          observeRoute: true,
        );
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreen(
        chatViewModelPvdr,
        chatViewCtrlPvdr,
      );
}

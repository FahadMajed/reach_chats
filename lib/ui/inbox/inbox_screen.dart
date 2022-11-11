import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatsInboxScreen extends ConsumerWidget {
  final bool withAnnouncements;
  final Function()? onIconPress;
  final Filter? filter;

  const ChatsInboxScreen({
    Key? key,
    this.withAnnouncements = false,
    this.onIconPress,
    this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final chatsListAsync = ref.watch(chatsStatePvdr);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("chats".tr),
        actions: [
          if (withAnnouncements)
            IconButton(
              onPressed: onIconPress,
              icon: const FaIcon(
                FontAwesomeIcons.bullhorn,
                size: iconSize16,
              ),
            )
        ],
      ),
      body: chatsListAsync.when(
        data: (chatsList) {
          chatsList = chatsList.where(filter ?? (c) => true).toList();

          return chatsList.isNotEmpty
              ? ListView.builder(
                  itemCount: chatsList.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      ChatListTile(
                        chat: chatsList[index],
                      ),
                      const Divider(
                        height: 0,
                        thickness: 0.5,
                      ),
                    ],
                  ),
                )
              : EmptyIndicator("no_chats_yet".tr);
        },
        error: (e, t) => ErrorWidget(e),
        loading: () => const Loading(),
      ),
    );
  }
}

typedef Filter = bool Function(Chat chat);

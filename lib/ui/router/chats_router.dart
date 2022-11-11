import 'package:flutter/material.dart';
import 'package:reach_auth/providers/providers.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/lib.dart';

class ChatsRouter extends ConsumerWidget {
  const ChatsRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final chats = ref.watch(chatsStatePvdr);
    final userId = ref.watch(userIdPvdr);

    return chats.when(
      data: (chatsList) {
        final hasNewMessages = ref.watch(chatsStateCtrlPvdr).hasNewMessages(userId);

        return IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => Get.to(() => const ChatsInboxScreen()),
          icon: Stack(
            children: [
              const Icon(
                Icons.mail_outline_outlined,
              ),
              hasNewMessages
                  ? Positioned(
                      left: 10,
                      child: ClipOval(
                        child: Container(
                          color: selectedColor,
                          alignment: Alignment.topLeft,
                          width: 10,
                          height: 10,
                        ),
                      ),
                    )
                  : const SizedBox(
                      width: 10,
                      height: 10,
                    ),
            ],
          ),
        );
      },
      error: (e, t) => ErrorWidget(e),
      loading: () => const Loading(),
    );
  }
}

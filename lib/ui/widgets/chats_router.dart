import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:reach_auth/providers/providers.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/ui/ui.dart';

class ChatsRouter extends ConsumerWidget {
  const ChatsRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    bool hasNewMessages = false;

    final chatsAsync = ref.watch(chatsPvdr);
    final userId = ref.watch(userIdPvdr);

    return chatsAsync.when(
      data: (chatsList) {
        for (final chat in chatsList) {
          if (chat.isLastMessageSeenByUser(userId) == false) {
            hasNewMessages = true;
          }
          break;
        }
        return IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => Get.to(const ChatsInboxScreen()),
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

import 'package:reach_auth/providers/providers.dart';
import 'package:reach_chats/domain/domain.dart';
import 'package:reach_chats/providers/chats_providers.dart';
import 'package:reach_chats/ui/ui.dart';
import 'package:reach_core/core/core.dart';

class ChatPresenter extends Presenter<ChatViewModel> {
  final List<Message> messages;
  final Chat chat;
  final String userId;

  ChatPresenter({
    required this.messages,
    required this.chat,
    required this.userId,
  });

  @override
  ChatViewModel presentViewModel() {
    final List<ChatElement> elements = [];

    for (Message m in messages) {
      // loop starts from newest to oldest
      DateTime currentMessageDate = m.timeStamp.toDate();

      DateTime nextMessageDate;

      bool areSameDayAndMonth = false;

      if (m != messages.last) {
        int currentMessageIndex = messages.indexOf(m);

        int nextMessageIndex = currentMessageIndex + 1;

        nextMessageDate = messages[nextMessageIndex].timeStamp.toDate();

        if (currentMessageDate.day == nextMessageDate.day && currentMessageDate.month == nextMessageDate.month) {
          areSameDayAndMonth = true;
        }
      }
      elements.add(
        MessageViewModel(
          message: m,
          fromMe: m.fromId == userId,
          sentAt: _formatSentAt(m.timeStamp),
          senderName: _getPeerName(m),
        ),
      );

      //first message, so its date must show
      if (m == messages.last) {
        elements.add(Date(_formatTimelineDate(m.timeStamp)));
      } else if (areSameDayAndMonth == false) {
        elements.add(Date(_formatTimelineDate(m.timeStamp)));
      }
    }
    return ChatViewModel(
      elements,
      appBarText: _getAppBarText(),
      imageUrl: _getPeerImageUrl(),
      peerImageColor: _getPeerColor(),
    );
  }

  String _getPeerName(Message message) {
    if (chat is GroupChat) {
      if (chat.researcher.researcherId == message.fromId) {
        return chat.researcher.name;
      } else {
        return (chat as GroupChat).participants.firstWhere((p) => p.participantId == message.fromId).name;
      }
    }
    return "";
  }

  String _formatSentAt(Timestamp timeStamp) {
    DateTime date = timeStamp.toDate();
    return ' ${date.hour}:${date.minute < 10 ? "0${date.minute}" : date.minute}';
  }

  String _formatTimelineDate(Timestamp timeStamp) {
    final dateToString = timeStamp.toDate().toString().substring(0, 10);
    return DateTime.now().toString().contains(dateToString) ? "today".tr : Formatter.parseDateNoTime(dateToString)!;
  }

  int _getPeerColor() {
    if (chat is GroupChat) {
      return chat.color;
    } else {
      if (peerIsResearcher) {
        return chat.researcher.defaultColor;
      } else {
        return (chat as PeerChat).participant.defaultColor;
      }
    }
  }

  String _getPeerImageUrl() {
    if (chat is GroupChat) {
      return "";
    } else {
      if (peerIsResearcher) {
        return chat.researcher.imageUrl;
      } else {
        return (chat as PeerChat).participant.imageUrl;
      }
    }
  }

  String _getAppBarText() {
    if (chat is GroupChat) {
      return (chat as GroupChat).groupName;
    } else {
      if (peerIsResearcher) {
        return chat.researcher.name;
      } else {
        return (chat as PeerChat).participant.name;
      }
    }
  }

  bool get peerIsResearcher => userId != chat.researcher.researcherId;
}

final chatViewModelPvdr = StateProvider<AsyncValue<ChatViewModel>>((ref) {
  final openedChat = ref.watch(openedChatPvdr);
  final userId = ref.watch(userIdPvdr);
  final messages = ref.watch(messagesStreamPvdr(openedChat.chatId));

  return messages.when(
      data: (messages) {
        final presenter = ChatPresenter(
          messages: messages,
          chat: openedChat,
          userId: userId,
        );
        final chatViewModel = presenter.presentViewModel();
        return AsyncData(chatViewModel);
      },
      error: (e, __) => AsyncError(e),
      loading: () => const AsyncLoading());
});

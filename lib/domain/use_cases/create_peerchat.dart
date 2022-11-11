import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class CreatePeerChat extends UseCase<PeerChat, CreatePeerChatRequest> {
  final ChatsRepository repository;
  final NotificationsRepository? notificationsRepository;

  CreatePeerChat(this.repository, this.notificationsRepository);

  late CreatePeerChatRequest _request;
  Researcher get researcher => _request.researcher;
  Participant get participant => _request.participant;
  String get researchId => _request.researchId;

  @override
  Future<PeerChat> call(CreatePeerChatRequest request) async {
    _request = request;

    final chatId = Formatter.formatChatId(
      researcher.researcherId,
      participant.participantId,
    );

    PeerChat peerChat = PeerChat(
      chatId: chatId,
      researcher: researcher,
      dateOpenedByMembers: {
        researcher.researcherId: Timestamp.now(),
        participant.participantId: Timestamp.now(),
      },
      researchsInCommon: researchId.isEmpty ? [] : [researchId],
      participant: participant,
      membersIds: [researcher.researcherId, participant.participantId],
      lastMessage: Message.init(researcher.researcherId),
      color: 0xFFFFFF,
    );

    notificationsRepository?.subscribeToChat(chatId);

    repository.createChat(peerChat);

    return peerChat;
  }
}

class CreatePeerChatRequest {
  final Researcher researcher;
  final Participant participant;
  final String researchId;

  CreatePeerChatRequest({
    required this.researcher,
    required this.participant,
    this.researchId = "",
  });
}

final createPeerChatPvdr = Provider<CreatePeerChat>((ref) => CreatePeerChat(
      ref.read(chatsRepoPvdr),
      ref.read(notificationsRepoPvdr),
    ));

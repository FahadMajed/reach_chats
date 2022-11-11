import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class CreateGroupChat extends UseCase<GroupChat, CreateGroupChatRequest> {
  final ChatsRepository repository;

  CreateGroupChat(this.repository);

  late CreateGroupChatRequest _request;

  @override
  Future<GroupChat> call(CreateGroupChatRequest request) async {
    _request = request;
    Map<String, dynamic> dateOpenedByMembers = {};
    final membersIds = [researcher.researcherId, for (final p in participants) p.participantId];
    for (String memberId in membersIds) {
      dateOpenedByMembers[memberId] = Timestamp.now();
    }
    GroupChat groupChat = GroupChat(
      chatId: groupId,
      researchsInCommon: [researchId],
      researcher: researcher,
      participants: participants,
      groupName: groupName,
      membersIds: membersIds,
      lastMessage: Message.init(researcher.researcherId),
      dateOpenedByMembers: dateOpenedByMembers,
      color: ColorGenerator.getRandomColor(),
    );

    repository.createChat(groupChat);

    return groupChat;
  }

  Researcher get researcher => _request.researcher;
  List<Participant> get participants => _request.participants;
  String get groupId => _request.groupId;
  String get researchId => _request.researchId;
  String get groupName => _request.groupName;
}

class CreateGroupChatRequest {
  final List<Participant> participants;
  final Researcher researcher;
  final String researchId;
  final String groupName;
  final String groupId;

  CreateGroupChatRequest({
    required this.participants,
    required this.researcher,
    required this.researchId,
    required this.groupId,
    required this.groupName,
  });
}

final createGroupChatPvdr = Provider<CreateGroupChat>((ref) => CreateGroupChat(
      ref.read(chatsRepoPvdr),
    ));

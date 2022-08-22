import 'package:reach_core/core/core.dart';

class Chat extends BaseModel<Chat> {
  //insert researcher and part object
  Chat(Map<String, dynamic> jSON) : super(jSON);

  String get chatId => data['chatId'];

  List get researchsInCommon => data['researchsInCommon'];

  Researcher get researcher => Researcher(data['researcher']);

  bool get isGroupChat => data['isGroupChat'];

  List get membersIds => data['membersIds'];

  Duration get sinceLastMessage =>
      DateTime.now().difference(data['lastMessageDate'].toDate());

  int get color => data['color'];

  Map<String, dynamic> get dateOpenedByMembers => data['dateOpenedByMembers'];

  Timestamp get lastMessageDate => data['lastMessageDate'];

  String get lastMessage => data['lastMessage'];

  String get lastMessageSenderId => data['lastMessageSenderId'];

  @override
  Chat copyWith(Map<String, dynamic> newData) => Chat(
        {
          ...data,
          ...newData..removeWhere((key, value) => value == null),
        },
      );

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'researcher': researcher.toPartialMap(),
      };

  @override
  List<Object?> get props => [toMap()];
}

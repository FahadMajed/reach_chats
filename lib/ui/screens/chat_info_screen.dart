import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reach/features/research%20mgt/ui/participants/widgets/widgets.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_research/research.dart';

class ChatInfoScreen extends ConsumerWidget {
  final GroupChat chat;
  const ChatInfoScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info"),
      ),
      body: ParticipantsListView(
        onTileTap: (e) {},
        enrollments: [
          for (final participant in chat.participants)
            Enrollment.init(participant, "")
        ],
      ),
    );
  }
}

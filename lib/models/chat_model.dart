import 'package:write_way_chat/models/local_message_model.dart';

// enum chatType {individual , group}
// extension ChatTypeEnumParsing on chatType{
//    String value() {
//     return this.toString().split('.').last;
//   }
//   static chatType fromString(String event)
//   {
//     return chatType.values.firstWhere((element) => element.value() == event);
//   }
// }

class Chat {
  String id;
  LocalMessageModel? mostRecentMessages;
  List<LocalMessageModel>? messages = [];
  int unread = 0;
  // chatType typeChat;
  Chat(this.id, {this.mostRecentMessages, this.messages});

  toMap() => {'id': id};

  factory Chat.fromMap(Map<String, dynamic> json) => Chat(json['id']);
}

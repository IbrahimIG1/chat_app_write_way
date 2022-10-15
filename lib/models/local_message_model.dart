import 'package:chat/chat.dart';

class LocalMessageModel {
  String get gId => _id!;
  String chatId;
  String? _id;
  MessageModel message;
  MessageReceiptStatus receipt;

  // pass Data To database
  Map<String, dynamic> toMap() => {
        'chat_id': chatId,
        'id': message.gId, //Message Id From Message Model
        ...message.toJson(), //  Message to Json From Message Model
        'receipt': receipt.value(),
      };
  // Receipt the data From database
  LocalMessageModel(this.chatId, this.message, this.receipt);
  factory LocalMessageModel.fromMap(Map<String, dynamic> json) {
    final MessageModel message = MessageModel(
      from: json['from'],
      messageContent: json['messageContent'],
      to: json['to'],
      timeStamp: json['timeStamp'],
    );
    final LocalMessageModel localMessage = LocalMessageModel(json['chat_id'],
        message, ReceiptEnumParsing.fromString(json['receipt']));
        localMessage._id = json['id'];
    return localMessage;
  }
}

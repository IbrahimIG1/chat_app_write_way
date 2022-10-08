

enum MessageStatus { sent, deliverred, read }

extension EnumParsing on MessageStatus {
  String value() {
    return this
        .toString()
        .split('.')
        .last; // to get last result from this (ReceiptStatus.send => sent)
  }

  static MessageStatus fromString(String status) {
    // it take value from me and put it in element.value()
    return MessageStatus.values
        .firstWhere((element) => element.value() == status);
  }
}

class MessageReadModel {
  String get gId => _id!;
  final String receiver;
  final String messageId;
  final DateTime messageTime;
  final MessageStatus messageStat;
  String? _id;
  MessageReadModel(
      {required this.messageId,
      required this.messageStat,
      required this.messageTime,
      required this.receiver});
  Map<String, dynamic> toJson() => {
        'receiver': receiver,
        'messageId': messageId,
        'messageTime': messageTime,
        'messageStat': messageStat.value(),
      };
  factory MessageReadModel.fromJson(Map<String, dynamic> json) {
    var model = MessageReadModel(
        messageId: json['messageId'],
        messageStat: EnumParsing.fromString(json['messageStat']),
        messageTime: json['messageTime'],
        receiver: json['receiver']);
    model._id = json['id'];
    return model;
  }
}

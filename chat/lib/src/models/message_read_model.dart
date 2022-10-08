enum MessageStatus { sent, deliverred, read }

extension EnumParsing on MessageStatus {
  String value() {
    return this.toString().split('.').last;
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
        'receipient': receiver,
        'messageId': messageId,
        'messageTime': messageTime,
        'messageStat': messageStat.value(),
      };
  factory MessageReadModel.fromJson(Map<String, dynamic> json) {
    var model = MessageReadModel(
        messageId: json['messageId'],
        messageStat: json['messageStat'],
        messageTime: json['messageTime'],
        receiver: json['receiver']);
    model._id = json['id'];
    return model;
  }
}

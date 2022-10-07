class MessageModel {
  String? get gId => _id;
  String messageContent;
  String to;
  String from;
  DateTime timeStamp;
  String? _id;

  MessageModel({
    required this.from,
    required this.messageContent,
    required this.to,
    required this.timeStamp,
  });
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final message = MessageModel(
        from: json['from'],
        messageContent: json['messageContent'],
        to: json['to'],
        timeStamp: json['timeStamp']);
    message._id = json['id'];
    return message;
  }
  toJson() => {
        'from': from,
        'messageContent': messageContent,
        'to': to,
        'timeStamp': timeStamp,
      };
}

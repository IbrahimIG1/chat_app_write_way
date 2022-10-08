enum Typing { start, stop }

extension TypingParser on Typing {
  String value() {
    return this.toString().split('.').last;
  }

  static Typing fromString(String event) {
    return Typing.values.firstWhere((element) => element.value() == event);
  }
}

class TypingEventModel {
  String get gId => _id!;
  final String from;
  final String to;
  final Typing event;
  String? _id;
  TypingEventModel({required this.from, required this.to, required this.event});

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'event': event.value(),
      };
  factory TypingEventModel.fromJson(Map<String, dynamic> json) {
    var model = TypingEventModel(
        from: json['from'],
        to: json['to'],
        event: TypingParser.fromString(json['event']));
    model._id = json['id'];
    return model;
  }
}

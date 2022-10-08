enum typingEvent { start, stop }

extension EnumParsing on typingEvent {
  String value() {
    return this.toString().split('.').last;
  }

  static typingEvent fromString(String status) {
    return typingEvent.values
        .firstWhere((element) => element.value() == status);
  }
}

class TypeEventModel {
  String get gId => _id!;
  final String from;
  final String to;
  final typingEvent typingStatus;
  String? _id;
  TypeEventModel(
      {required this.from, required this.to, required this.typingStatus});

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'typingStatus': typingStatus,
      };
  factory TypeEventModel.fromJson(Map<String, dynamic> json) {
    var model = TypeEventModel(
        from: json['from'], to: json['to'], typingStatus: json['typingStatus']);
    model._id = json['id'];
    return model;
  }
}

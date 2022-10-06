class User {
  String? get gId => id;
  String userName;
  String photoUrl;
  bool active;
  DateTime lastSeen;
  String? id;
  User({
    required this.active,
    required this.lastSeen,
    required this.photoUrl,
    required this.userName,
  });
  toJson()=>
  {
    'userName':userName,
    'lastSeen':lastSeen,
    'photoUrl':photoUrl,
    'active':active,
  };
  factory User.fromJson(Map<String,dynamic>json)
  {
    final user = User
    (
      active: json['active'],
      lastSeen: json['lastSeen'],
      photoUrl: json['photoUrl'],
      userName: json['userName'],
    );
    return user;
  }
}

import 'package:chat/src/models/type_event_model.dart';
import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/type_event/type_event_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  TypingNotification? sut;
  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDb(r, connection!);
    sut = TypingNotification(r, connection!);
  });
  tearDown(() async {
    sut!.dispose();
    // cleanDb(r, connection!);
  });

  final user1 = User.fromJson({
    'id': '1234',
    'active': true,
    'userName': 'ibrahim typing',
    'photoUrl': 'url',
    'lastSeen': DateTime.now()
  });
  final user2 = User.fromJson({
    'id': '1111',
    'active': true,
    'userName': 'uossef typing',
    'photoUrl': 'url',
    'lastSeen': DateTime.now()
  });
  test('sent Typing notification successfully', () async {
    TypingEventModel typingEventModel =
        TypingEventModel(from: user2.gId!, to: user1.gId!, event: Typing.start);

    final res = await sut!.sent(event: typingEventModel, to: user1);
    expect(res, true);
  });
  test('Successfully subscribe and recive typing events', () async {
    sut!.subscribe(user2, [user1.gId!]).listen(expectAsync1((event) {
      expect(event.from, user1.gId!);
    }, count: 2));
    TypingEventModel typing =
      TypingEventModel(from: user1.gId!, to: user2.gId!, event: Typing.start);
  TypingEventModel typingStop =
      TypingEventModel(from: user1.gId!, to: user2.gId!, event: Typing.stop);
      await sut!.sent(event: typing, to: user2);
      await sut!.sent(event: typingStop, to: user2);
  });
  
}

import 'package:chat/src/models/message_model.dart';
import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  MessageService? sut;

  setUp(() async {
    sut = MessageService(r, connection!);
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDb(r, connection!);
  });
  tearDown(() {
    sut!.dispose();
    cleanDb(r, connection!);
  });
  test('message sent successfully', () {
    MessageModel message = MessageModel(
        from: 'from',
        messageContent: 'hello',
        to: 'to',
        timeStamp: DateTime.now());
    final sentMessage = sut!.sent(message);
    expect(sentMessage, true);
  });
  User user1 = User(
      active: true,
      lastSeen: DateTime.now(),
      photoUrl: 'photoUrl',
      userName: 'ibrahim');
  User user2 = User(
      active: false,
      lastSeen: DateTime.now(),
      photoUrl: 'photoUrl',
      userName: 'uossef'); // who recevie message
  test('recieving message in stream', () {
    sut!.messages(user2).listen(expectAsync1((message) {
          expect(message.to, user2);  // التأكد من أن اليوزر 2 هو الى استلم الرسالة
          expect(message.gId, isNotEmpty); // التأكد من أن الاى دى بتاع الرسالة مش فاضي 
          expect(message.messageContent, 'hello'); // محتوى الرسالة hello
        }, count: 2));
  });
}

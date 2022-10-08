import 'package:chat/src/models/message_model.dart';
import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/encryption/encrytion_service_impl.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  MessageService? sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDb(r, connection!);
    final encryptionService =
        EncryptionService(Encrypter(AES(Key.fromLength(32))));
    sut = MessageService(r, connection!, encryptionService);
  });
  tearDown(() async {
    sut!.dispose();
    await cleanDb(r, connection!);
  });

  User user1 = User.fromJson({
    'id': '1111',
    'userName': 'user1',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now()
  });
  User user2 = User.fromJson({
    'id': '2222',
    'userName': 'user2',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now()
  }); // who recevie message

  test('message sent successfully', () async {
    MessageModel message = MessageModel(
        from: user1.gId!,
        messageContent: 'hello',
        to: '3456',
        timeStamp: DateTime.now());
    final sentMessage = await sut!.sent(message);
    expect(sentMessage, true);
  });

  test('recieving message in stream', () async {
    String content = 'this is a message';
    sut!.messages(user2).listen(expectAsync1((message) {
          expect(message.to, user2.gId);
          expect(message.gId, isNotEmpty);
          expect(message.messageContent, content);
        }, count: 2));
    MessageModel message = MessageModel(
        from: user1.gId!,
        to: user2.gId!,
        messageContent: content,
        timeStamp: DateTime.now());
    //  create message 2 for test
    MessageModel secondMessage = MessageModel(
        from: user1.gId!,
        to: user2.gId!,
        messageContent: content,
        timeStamp: DateTime.now());
    await sut!.sent(message); // call send method to check  message is send?
    await sut!.sent(secondMessage);
  });
}

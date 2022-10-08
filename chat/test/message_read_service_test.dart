import 'package:chat/src/models/message_read_model.dart';
import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/message_read/message_read_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  MessageReadService? sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    sut = MessageReadService(r, connection!);
    await createDb(r, connection!);
  });
  tearDown(() async {
    sut!.dispose();
    await cleanDb(r, connection!);
  });
  test('sent message read success', () async {
    var messageReadModel = MessageReadModel(
        messageId: '123',
        messageStat: MessageStatus.deliverred,
        messageTime: DateTime.now(),
        receiver: '0000');
    final res = await sut!.sent(messageReadModel);
    expect(res, true);
  });
  User user = User.fromJson({
    'id': '1234',
    'active': true,
    'lastSeen': DateTime.now(),
    'userName': 'ibra',
    'photoUrl': 'image'
  });
  test('successfully subscribe and receive receipts', () async {
    sut!.userMessageModelReceivers(user).listen(expectAsync1((receipt) {
          expect(receipt.receiver, user.gId);
        }, count: 2));
    MessageReadModel receipt1 = MessageReadModel(
        messageId: '1234',
        messageStat: MessageStatus.deliverred,
        messageTime: DateTime.now(),
        receiver: user.gId!);
    MessageReadModel receipt2 = MessageReadModel(
        messageId: '1234',
        messageStat: MessageStatus.deliverred,
        messageTime: DateTime.now(),
        receiver: user.gId!);
    await sut!.sent(receipt1);
    await sut!.sent(receipt2);
  });
}

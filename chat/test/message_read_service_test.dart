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

  setUp(() {
    sut = MessageReadService(r, connection!);
    createDb(r, connection);
  });
  tearDown(() {
    sut!.dispose();
    cleanDb(r, connection!);
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
  User user = User(
      active: true,
      lastSeen: DateTime.now(),
      photoUrl: 'photoUrl',
      userName: 'ibrahim');
  test('successfully subscribe and receive receipts', () {
    sut!.userMessageModelReceivers(user).listen(expectAsync1((receipt) {
          expect(receipt.receiver, user.gId);
        }, count: 2));
  });
}

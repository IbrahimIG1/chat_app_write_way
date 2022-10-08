import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/user/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  UserService? sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection!); // create tables first
    sut = UserService(r, connection!);
  });

  tearDown(() async {
    // await cleanDb(r, connection!);
  });

  test('create new user in database', () async {
    final user = User(
      active: true,
      lastSeen: DateTime.now(),
      photoUrl: 'photoUrl',
      userName: 'Ibrahim',
    );

    final userWithId = await sut!.connect(user);

    expect(userWithId.id, isNotEmpty);
  });
  test('get online user', () async {
    final user = User(
      userName: 'test 2',
      photoUrl: 'url 2',
      active: true,
      lastSeen: DateTime.now(),
    );
    await sut!.connect(
        user);
    final users = await sut!.online();
    expect(users.length, 1);
  });
  test('user disconnect update data done', () async {
    final user = User(
      active: false,
      lastSeen: DateTime.now(),
      photoUrl: 'photoUrl',
      userName: 'Ibrahim',
    );
    final userDisConnect = await sut!.disConnect(user);
  });
}

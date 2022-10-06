import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDb(RethinkDb r, Connection connection) async {
await r.table('test').run(connection).catchError((error) {
    print('Error in helper Create test table =>$error');
  });

  await r.table('users').run(connection).catchError((error) {
    print('Error in helper Create user table =>$error');
  });
}

Future<void> cleanDp(RethinkDb r ,Connection connection)
async{
  await r.table('users').delete().run(connection);
}

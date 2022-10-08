
import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDb(RethinkDb r, Connection connection) async {
 await r.dbCreate('test').run(connection).catchError((err) => {});
  await r.tableCreate('users').run(connection).catchError((err) => {}); // create Users Table
  await r.tableCreate('messages').run(connection).catchError((err) => {}); // create messages Table
  await r.tableCreate('messageReceipts').run(connection).catchError((err) => {}); // create receipts Table
}

Future<void> cleanDb(RethinkDb r, Connection connection) async 
{
  await r.table('users').delete().run(connection); // delete Users Table
  await r.table('messages').delete().run(connection); // delete messages Table
  await r.table('messageReceipts').delete().run(connection); // delete receipts Table
}

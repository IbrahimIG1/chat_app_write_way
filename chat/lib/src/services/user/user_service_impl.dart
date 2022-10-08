import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  final Connection _connection;
  final RethinkDb r;
  UserService(this.r, this._connection);
  @override
  //  https://rethinkdb.com/api/javascript/insert/  (documents شرح)

  Future<User> connect(User user) async {
    var data = user.toJson(); //  data to json To save in database
    if (user.gId != null) data['id'] = user.gId; // get id from database and save in user model
    final result = await r
        .table('users')
        .insert(data /* put data in users table in database */, {
      'conflict': 'update', // to put this new value in table
      'return_changes': true, // return data when save in database
    }).run(_connection);
    return User.fromJson(result['changes']
        .first['new_val']); // new_val the new value which updated
  }

  @override
  Future<void> disConnect(User user) async {
    await r.table('users').update({
      'id': user.gId,
      'active': false, // update active to false mean user is disconnect
      'lastSeen': DateTime.now() // last seen
    }).run(_connection);
    _connection.close();
  }

  @override
  Future<List<User>> online() async {
    //  Cursor : to get data in stream whien updated (active: true )
    Cursor users = await r.table('users').filter({'active': true}).run(
        _connection); // (active: true ) => save user data in users
    final usersList =
        await users.toList(); // users to List and put in usersList
    return usersList.map((e) => User.fromJson(e)).toList();
    //usersList to map , get elements from database and pass to fromJson to save in List
  }
  
  @override
  Future<User> fetch(String id) async {
    final user = await r.table('users').get(id).run(_connection);
    return User.fromJson(user);
  }
}

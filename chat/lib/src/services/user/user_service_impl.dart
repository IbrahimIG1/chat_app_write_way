import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  final Connection _connection;
  final RethinkDb r;
  UserService(this._connection, this.r);
  @override
  Future<User> connect(User user) async {
    var data = user.toJson();
    if (user.gId != null) data['id'] = user.gId;
    final result = await r.table('users').insert(
        data, {'conflict': 'update', 'return_changes': true}).run(_connection);
    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disConnect(User user) {
    // TODO: implement disConnect
    throw UnimplementedError();
  }

  @override
  Future<List<User>> online() {
    // TODO: implement online
    throw UnimplementedError();
  }
}

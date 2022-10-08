 import 'package:chat/src/models/user_model.dart';

abstract class IUserService
{
  Future<User> connect(User user);  //  set(save) user data on server database
  Future<List<User>> online();  //  get online users
  Future<void> disConnect(User user); //  update user active status
  Future<User> fetch(String id);
}
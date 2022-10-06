 import 'package:chat/src/models/user_model.dart';

abstract class IUserService
{
  Future<User> connect(User user);
  Future<List<User>>online();
  Future<void> disConnect(User user);
}
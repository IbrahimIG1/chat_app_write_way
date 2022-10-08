import 'package:chat/src/models/message_model.dart';
import 'package:chat/src/models/user_model.dart';

abstract class IMessageService {
  Future<bool> sent(MessageModel message);  // return true when message sent
  Stream<MessageModel> messages(User activeUser); // listen to messages reciving and send
  dispose();  // close stream
}

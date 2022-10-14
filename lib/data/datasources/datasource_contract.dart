import 'package:chat/chat.dart';
import 'package:write_way_chat/models/local_message_model.dart';

import '../../models/chat_model.dart';

abstract class IDatasource
{
  Future<void> addChat(Chat chat);  // add chat to database
  Future<void>addMessage(LocalMessageModel message); //   add the local message to database
  Future<Chat>findChat(String chatId);
  Future<List<Chat>>findAllChats();
  Future<void>updateMessage(LocalMessageModel message);
  Future<List<LocalMessageModel>>findMesasges(String chatId);
  Future<void>deleteChat(String chatId);
  

}
import 'package:chat/chat.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'package:write_way_chat/view_models/base_view_model.dart';

import '../data/datasource_contract.dart';

class ChatViewModel extends BaseViewModel {
  final IDatasource _datasource;
  String _chatId = ''; // to hold chat id
  int otherMessages = 0; // to controll in new messages comming in other chats
  ChatViewModel(this._datasource) : super(_datasource);

  // get message from database to in chat
  Future<List<LocalMessageModel>> getMessages(String chatId) async {
    final message = await _datasource
        .findMesasges(chatId); // get messages in chatId from database
    if (message.isNotEmpty) _chatId = chatId; // hold the chat id
    return message;
  }

  //  sent message to any one
  Future<void> sentMessage(MessageModel message) async {
    final localMessage = LocalMessageModel(
        message.to,
        message,
        MessageReceiptStatus
            .sent); // save message data to local message in database
    if (_chatId.isNotEmpty) {
      await _datasource.addMessage(localMessage);
    } else {
      _chatId = localMessage.chatId;
      await addMessage(localMessage); // chat is old and existing
    } // check if chat_id is not empty(that mean create chat)
  }

  Future<void> receivedMessage(MessageModel message) async {
    final localMessage = LocalMessageModel(
        message.from, message, MessageReceiptStatus.deliverred);
    print('localMessage');
    if (_chatId.isEmpty) {
      _chatId = localMessage.chatId;
      print('_chatId is empty if ');
    }
    if (localMessage.chatId != _chatId) {
      otherMessages++; // receive message from onther chat
      print('otherMessages ++');
    }
    print('befor addMessage');
    await addMessage(localMessage); //  add message which i received to database
    print('addMessage done');
  }
}

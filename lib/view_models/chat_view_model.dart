import 'package:chat/chat.dart';
import 'package:write_way_chat/data/datasources/datasource_contract.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'package:write_way_chat/view_models/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  IDatasource _datasource;
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
            .sent); //  save message data to local message in database
    if (_chatId.isNotEmpty)
      await _datasource.addMessage(
          localMessage); // check if chat_id is not empty(that mean create chat)
    _chatId = localMessage.chatId;
    await addMessage(localMessage); // chat is old and existing
  }

  Future<void> receivedMessage(MessageModel message) async {
    final localMessage = LocalMessageModel(
        message.from, message, MessageReceiptStatus.deliverred);
        if(localMessage.chatId != _chatId) otherMessages++; // receive message from onther chat
        await addMessage(localMessage); //  add message which i received to database
  }
}

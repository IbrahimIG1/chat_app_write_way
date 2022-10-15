import 'package:chat/chat.dart';
import 'package:write_way_chat/data/datasources/datasource_contract.dart';
import 'package:write_way_chat/models/chat_model.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'package:write_way_chat/view_models/base_view_model.dart';

class ChatsViewModel extends BaseViewModel {
  IDatasource _datasource;
  
  ChatsViewModel(this._datasource) : super(_datasource);
  //  Get All Chats In Main Screen 
  Future<List<Chat>> getChats() async=>await _datasource.findAllChats();
  
  Future<void> receivedMessage(MessageModel message) async {
    LocalMessageModel localMessage = LocalMessageModel(
        message.from, message, MessageReceiptStatus.deliverred);
    await addMessage(localMessage);
  }
}

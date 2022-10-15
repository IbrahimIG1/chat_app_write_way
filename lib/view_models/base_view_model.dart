import 'package:flutter/material.dart';
import 'package:write_way_chat/data/datasources/datasource_contract.dart';
import 'package:write_way_chat/models/local_message_model.dart';

import '../models/chat_model.dart';

abstract class BaseViewModel {
  IDatasource _datasource;
  BaseViewModel(this._datasource);

 @protected
  Future<void> addMessage(LocalMessageModel message) async {
    //  check is chat Existing Or Create it
    if (!await _isExistingChat(message.chatId)) {
      final chat = Chat(message.chatId);
      await createNewChat(chat);
    }
    // add message after make sure the chat is existing
    await _datasource.addMessage(message);
  }

  Future<bool> _isExistingChat(String chatId) async {
    //  search for chat is existing in database or not(null)
    return await _datasource.findChat(chatId)!=null;
  }

  Future<void> createNewChat(Chat chat) async {
    //  create chat in database if it isn't exist
    await _datasource.addChat(chat);
  }
}

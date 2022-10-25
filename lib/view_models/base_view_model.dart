import 'package:flutter/material.dart';
import 'package:write_way_chat/models/local_message_model.dart';

import '../data/datasource_contract.dart';
import '../models/chat_model.dart';

abstract class BaseViewModel {
  final IDatasource _datasource;
  BaseViewModel(this._datasource);

 @protected
  Future<void> addMessage(LocalMessageModel message) async {
    print('in add message');
    //  check is chat Existing Or Create it
    if (!await _isExistingChat(message.chatId)) {
    print('in _isExistingChat if ');
    print(_isExistingChat.toString());

      final chat = Chat(message.chatId);
      await createNewChat(chat);
    }

    // add message after make sure the chat is existing
    print(' addMessage after if ');
    await _datasource.addMessage(message);  
    print('end  addMessage  ');

  }

  Future<bool> _isExistingChat(String chatId) async {
    print('in _isExistingChat func ');
    print(chatId);
    //  search for chat is existing in database or not(null)
    return await _datasource.findChat(chatId)!=null;
  }

  Future<void> createNewChat(Chat chat) async {
    print('in createNewChat func ');

    //  create chat in database if it isn't exist
    await _datasource.addChat(chat);
  }
}

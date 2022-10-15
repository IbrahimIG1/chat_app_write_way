import 'package:sqflite/sqflite.dart';
import 'package:write_way_chat/data/datasources/datasource_contract.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'package:write_way_chat/models/chat_model.dart';

class SqflitDataSource implements IDatasource {
  Database _db;
  SqflitDataSource(this._db);
  @override
  Future<void> addChat(Chat chat) async {
    print('in add chat create');
    await _db.insert('chats', chat.toMap(), // save chat model in database
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> addMessage(LocalMessageModel message) async {
    await _db.insert(
        'messages', message.toMap(), // save message model in database
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch =
        _db.batch(); // batch help to remove both thing in the same time
    batch.delete('messages',
        where: 'chat_id = ?',
        whereArgs: [chatId]); // delete messages from database
    batch.delete('chats',
        where: 'id = ?', whereArgs: [chatId]); // delete chats from database
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() {
    return _db.transaction((txn) async {
      //  get the last messages by timeStamp in messages table
      final chatsWithLatestMessages =
          await txn.rawQuery(''' SELECT messages.* FROM
      (SELECT
        chat_id, MAX(created_at) AS created_at
        FROM messages
        GROUP BY chat_id
      ) AS lastest_messages
      INNER JOIN lastest_messages
      ON messages.chat_id = lastest_messages.chat_id
      AND messages.created_at = lastest_messages.created_at
     ''');
      // get messages wasn't read from messages table
      final chatsWithUnreadMessages =
          await txn.rawQuery(''' SELECT chat_id, count(*) AS unread
     FROM messages
     WHERE receipt = ?
     GROUP BY chat_id
     ''', ['deliverred']);

      // get message by message to save it in variable and pass to database
      return chatsWithLatestMessages.map<Chat>((row) {
        //  get unread message by message to save it in variable and pass to database
        final int? unread = int.tryParse((chatsWithUnreadMessages.firstWhere(
                (element) => row['chat_id'] == element['chat_id'],
                orElse: () => {'unread': 0})['unread'])
            .toString());

        final chat = Chat.fromMap(row);
        chat.unread = unread!;
        chat.mostRecentMessages = LocalMessageModel.fromMap(row);

        return chat;
      }).toList();
    });
  }

  @override
  Future findChat(String chatId) async {
    print('in find chat func ');
    return await _db.transaction((txn) async {
    print('start transaction ');

      final listOfChatMap =
          await txn.query('chats', where: 'id = ?', whereArgs: [chatId]);
      if (listOfChatMap.isEmpty) {
        print('List of chat is empty ');
        return null;
      }
      final unread = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
          [chatId, 'deliverred']));
        print('unread done');

      final mostRecentMessages = await txn.query('messages',
          where: 'chat_id = ?',
          whereArgs: [chatId],
          orderBy: 'created_at DESC',
          limit: 1);
        print('mostRecentMessages done');
          
      final chat = Chat.fromMap(listOfChatMap.first);
      chat.unread = unread!;
      if (mostRecentMessages.isNotEmpty) {
        chat.mostRecentMessages =
          LocalMessageModel.fromMap(mostRecentMessages.first);
      }
      return chat;
    });
  }

  @override
  // get message from messages table in database
  Future<List<LocalMessageModel>> findMesasges(String chatId) async {
    final listOfMaps = await _db.query('messages',
        where: 'chat_id = ?',
        whereArgs: [chatId]); // get the chat_id row in table

    // get the information from chat_id row in table (LocalMessageModel messages) and return it one by one
    return listOfMaps
        .map<LocalMessageModel>((map) => LocalMessageModel.fromMap(map))
        .toList();
  }

  @override
  Future<void> updateMessage(LocalMessageModel message) async {
    await _db.update('messages', message.toMap(),
        where: 'id = ?',
        whereArgs: [message.message.gId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:write_way_chat/data/datasources/datasource_contract.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'package:write_way_chat/models/chat_model.dart';

class SqflitDataSource implements IDatasource {
  Database _db;
  SqflitDataSource(this._db);
  @override
  Future<void> addChat(Chat chat) async {
    await _db.insert('chats', chat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> addMessage(LocalMessageModel message) async {
    await _db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _db.batch();
    batch.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
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
  Future<Chat> findChat(String chatId) async {
    return await _db.transaction((txn) async {
      final listOfChatMap =
          await txn.query('chats', where: 'id = ?', whereArgs: [chatId]);
      final unread = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
          [chatId, 'deliverred']));
      final mostRecentMessages = await txn.query('messages',
          where: 'chat_id = ?',
          whereArgs: [chatId],
          orderBy: 'created_at DESC',
          limit: 1);
      final chat = Chat.fromMap(listOfChatMap.first);
      chat.unread = unread!;
      chat.mostRecentMessages =
          LocalMessageModel.fromMap(mostRecentMessages.first);
      return chat;
    });
  }

  @override
  Future<List<LocalMessageModel>> findMesasges(String chatId) async {
    final listOfMaps =
        await _db.query('messages', where: 'chat_id = ?', whereArgs: [chatId]);
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

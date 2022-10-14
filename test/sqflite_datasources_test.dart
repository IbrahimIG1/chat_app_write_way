import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:write_way_chat/data/datasources/datasource_impl.dart';
import 'package:write_way_chat/models/chat_model.dart';
import 'package:write_way_chat/models/local_message_model.dart';

import 'sqflite_datasources_test.mocks.dart';

@GenerateMocks([Database])
// @GenerateNiceMocks([
//   MockSpec<MockDatabase>(),
// ])
void main() {
  SqflitDataSource? sut;
  MockDatabase? database;
  // MockSBatch? batch;
  setUp(() {
    database = MockDatabase();
    // batch = MockSBatch();
    sut = SqflitDataSource(database!);
  });
  final message = MessageModel.fromJson({
    'from': '111',
    'to': '222',
    'messageContent': 'hey',
    'timeStamp': DateTime.parse('2022-07-13'),
    'id': '4444'
  });
  test('should perform insert of chat to the database', () async {
    final chat = Chat('1234');
    // database.transaction((p0) => null)
    try {
      when(database!.insert('chats', chat.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);
    } catch (e) {
      print('error in try $e');
    }

    await sut!.addChat(chat);
    verify(database!.insert('chats', chat.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .called(1);
  });
  test('should perform insert of message to the database', () async {
    final localMessage =
        LocalMessageModel('4444', message, MessageReceiptStatus.sent);
    when(database!.insert('messages', localMessage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .thenAnswer((realInvocation) async => 1);
    await sut!.addMessage(localMessage);
    verify(database!.insert('messages', localMessage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .called(1);
  });
  test('should perform a database query and return a message', () async {
    final messagesMap = [
      {
        'from': '111',
        'to': '222',
        'messageContent': 'hey',
        'timeStamp': DateTime.parse('2022-07-13'),
        'id': '4444',
        'chat_id': '111',
        'receipt': 'sent'
      }
    ];
    when(database!.query('messages',
            where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
        .thenAnswer((realInvocation) async => messagesMap);
    var messages = await sut!.findMesasges('111');
    expect(messages.length, 1);
    expect(messages.first.chatId, '111');
    verify(database!.query('messages',
            where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
        .called(1);
  });
}

import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:write_way_chat/data/datasource_impl.dart';
import 'package:write_way_chat/models/chat_model.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'sqflite_datasources_test.mocks.dart';

@GenerateMocks([Database])  // @GenerateMocks to init mockito class and run with out null error
@GenerateMocks([Batch])

// @GenerateNiceMocks([
//   MockSpec<MockDatabase>(),
// ])
void main() {
  SqflitDataSource? sut;
  MockDatabase? database;
  MockBatch? batch;
  setUp(() {
    database = MockDatabase();
    batch = MockBatch();
    sut = SqflitDataSource(database!);
  });
  //  message receve from database 
  final message = MessageModel.fromJson({
    'from': '111',
    'to': '222',
    'messageContent': 'hey',
    'timeStamp': DateTime.parse('2022-07-13'),
    'id': '4444'
  });
  test('should perform insert of chat to the database', () async {
    final chat = Chat('1234'); // add this chat to database
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
  test('should perform a database update a message', () async {
    final localMessage =
        LocalMessageModel('1234', message, MessageReceiptStatus.sent);
    when(
      database!.update('messages', localMessage.toMap(),
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          conflictAlgorithm: ConflictAlgorithm.replace),
    ).thenAnswer((realInvocation) async => 1);
    await sut!.updateMessage(localMessage);
    verify(
      database!.update('messages', localMessage.toMap(),
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          conflictAlgorithm: ConflictAlgorithm.replace),
    ).called(1);
  });
  test('should perform a database batch delete a message', () async {
    final chatId = '111';
    when(database!.batch()).thenReturn(batch!);
    await sut!.deleteChat(chatId);
    verifyInOrder([
      database!.batch(),
      batch!.delete('messages', where: anyNamed('where'), whereArgs: [chatId]),
      batch!.delete('chats', where: anyNamed('where'), whereArgs: [chatId]),
      batch!.commit(noResult: true)
    ]);
  });
}

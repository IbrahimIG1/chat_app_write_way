import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:write_way_chat/data/datasource_contract.dart';
import 'package:write_way_chat/models/chat_model.dart';
import 'package:write_way_chat/models/local_message_model.dart';
import 'package:write_way_chat/view_models/chat_view_model.dart';

import 'chats_view_model_test.mocks.dart';

@GenerateMocks([IDatasource])
void main() {
  ChatViewModel? sut;
  MockIDatasource? mockIDatasource;
  setUp(() {
    mockIDatasource = MockIDatasource();
    sut = ChatViewModel(mockIDatasource!);
  });
  final message = MessageModel.fromJson({
    'from': '111',
    'to': '222',
    'messageContent': 'hey',
    'timeStamp': DateTime.parse('2000-07-13')
  });
  test('initial messages return empty list', () async {
    when(mockIDatasource!.findMesasges(any))
        .thenAnswer((_) async => []); // when findMessages done return []
    expect(await sut!.getMessages('123'),
        isEmpty); //  check when getMessages(findMessages) done the return result is [] => (test done)
  });
  test('returns list of messages from local storage', () async {
    final chat = Chat('123'); // chat for test
    final localMessages = LocalMessageModel(
        chat.id,
        message,
        MessageReceiptStatus
            .deliverred); // message for test take chat id (this message deliverred in chat)
    when(mockIDatasource!.findMesasges(chat.id)).thenAnswer(
        (realInvocation) async =>
            [localMessages]); // find message in chat and return it
    final mess = await sut!.getMessages('123'); // get message from chat id
    expect(mess, isNotEmpty); // expect the chat is not empty and have a message
    expect(mess.first.chatId,
        '123'); // expect the mess in chat have the Id ('123')
  });

  //  this test to add new chat when send message (no add new empty chat without messages in it (sending message first then create chat in database))
  test('creates a new chat when sending first messages', () async {
    when(mockIDatasource!.findChat(any)).thenAnswer((_) async => null);
    await sut!.sentMessage(message);
    verify(mockIDatasource!.addChat(any)).called(1);
  });
  test('add new sent message to the chat', () async {
    final chat = Chat('123');
    final localMessage =
        LocalMessageModel(chat.id, message, MessageReceiptStatus.sent);

    // when(mockIDatasource!.findChat(chat.id))
    //     .thenAnswer((realInvocation) async => chat);

    when(mockIDatasource!.findMesasges(chat.id))
        .thenAnswer((_) async => [localMessage]);
    await sut!.getMessages(chat.id);
    await sut!.sentMessage(message);

    verifyNever(mockIDatasource!.addChat(any));
    verify(mockIDatasource!.addMessage(any)).called(1);
  });

  test('add new received message to the chat', () async {
    final chat = Chat('111');
    final localMessage =
        LocalMessageModel(chat.id, message, MessageReceiptStatus.deliverred);

    when(mockIDatasource!.findMesasges(chat.id)).thenAnswer((_) async =>
        [localMessage]); //  find message in messages table and return messages
    when(mockIDatasource!.findChat(chat.id))
        .thenAnswer((realInvocation) async => chat);

    await sut!.getMessages(chat.id); // get messages in chatId
    await sut!.receivedMessage(message); // received message
    verifyNever(mockIDatasource!.addChat(any)); // no  add chat never
    verify(mockIDatasource!.addMessage(any))
        .called(1); //add message which received to database
  });
  test('creates a new chat when message received is not apart of this chat',
      () async {
    final chat = Chat('123');
    final localMessage =
        LocalMessageModel(chat.id, message, MessageReceiptStatus.deliverred);

    when(mockIDatasource!.findMesasges(chat.id)).thenAnswer((_) async =>
        [localMessage]); //  find message in messages table and return messages
    when(mockIDatasource!.findChat(chat.id)).thenAnswer((_) async => null);

    await sut!.getMessages(chat.id); // get messages in chatId
    print('getMessages done');

    await sut!.receivedMessage(message); // received message
    print('receivedMessage done');

    verify(mockIDatasource!.addChat(any)).called(1); // add chat
    print('addChat done');

    verify(mockIDatasource!.addMessage(any)).called(1);
    print('addMessage done');
    expect(sut!.otherMessages, 1);
    print('expect done');
  });
}

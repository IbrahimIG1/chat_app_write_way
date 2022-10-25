import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:write_way_chat/data/datasource_contract.dart';
import 'package:write_way_chat/models/chat_model.dart';
import 'package:write_way_chat/view_models/chats_view_model.dart';

import 'chats_view_model_test.mocks.dart';

@GenerateMocks([IDatasource])
void main() {
  ChatsViewModel? sut;
  MockIDatasource? mockDatasource;
  setUp(() {
    mockDatasource = MockIDatasource();
    sut = ChatsViewModel(mockDatasource!);
  });
  final message = MessageModel.fromJson({
    'from': '111',
    'to': '222',
    'messageContent': 'hey',
    'timeStamp': DateTime.parse('2000-07-13')
  });
  test('initial chats return empty list', () async {
    when(mockDatasource!.findAllChats())
        .thenAnswer((_) async => []); // when findAllChats done return []
    expect(await sut!.getChats(),
        isEmpty); //  check when getChats(findAllChats) done the return result is [] => (test done)
  });
  test('returns list of chat', () async {
    final chat = Chat('123');
    when(mockDatasource!.findAllChats()).thenAnswer(
        (realInvocation) async => [chat]); // return chat when getAllChats Done

    final chats = await sut!
        .getChats(); // getChat have the chat which return ^ (mean the get chat is not empty)

    expect(chats, isNotEmpty); // check chats is empty or not (test done)
  });
  test('creates a new chat when receiving message foe the first time',
      () async {
         Chat? chat ;
    when(mockDatasource!.findChat(any)).thenAnswer((_) async => null);  // when findChat (any) Done return null value (chat not exist) 
    await sut!.receivedMessage(message);  // create new chat and receve the message 
    verify(mockDatasource!.addChat(any)).called(1); // add chat 
  });
  test('add new message to exsithin chat', ()
  async{
    final chat = Chat('123');
    when(mockDatasource!.findChat(any)).thenAnswer((_) async=> null);
    await sut!.receivedMessage(message);
    verifyNever(mockDatasource!.addChat(chat)); // to make sure the addChat doesn't called never because caht is find Already
    verify(mockDatasource!.addMessage(any)).called(1);
  });
}

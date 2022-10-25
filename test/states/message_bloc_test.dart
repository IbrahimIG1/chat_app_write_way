import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:write_way_chat/states_management/message_bloc.dart';

import 'message_bloc_test.mocks.dart';

@GenerateMocks([IMessageService])
void main() {
  MessageBloc? sut;
  IMessageService? messageService;
  User? user;
  setUp(() {
    messageService = MockIMessageService();
    user = User(
        active: true,
        lastSeen: DateTime.now(),
        photoUrl: 'photoUrl',
        userName: 'ibrahim');
    sut = MessageBloc(messageService!);
  });
  tearDown(() => sut!.close());
  test('should emit initial state only without subscription', () {
    expect(sut!.state, MessageInitial());
  });
  test('should emit message sent state when message sent', () async{
    final message = MessageModel(
        from: '123',
        messageContent: 'test message',
        to: '456',
        timeStamp: DateTime.now());
    when(messageService!.sent(message)).thenAnswer((_) async => true);
    sut!.add(MessageEvent.messageSent(message));
    expectLater(sut!.stream, emits(MessageState.sent(message)));
  });
  test('should emit message Received from service', () async{
    final message = MessageModel(
        from: '123',
        messageContent: 'test message',
        to: '456',
        timeStamp: DateTime.now());
    when(messageService!.messages(user!)).thenAnswer((_) => Stream.fromIterable([message]));
    sut!.add(MessageEvent.subscribed(user!));
    expectLater(sut!.stream, emitsInOrder([MessageReceivedSuccess(message)]));
  });
}

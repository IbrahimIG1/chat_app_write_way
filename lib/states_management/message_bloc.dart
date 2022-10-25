import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chat/chat.dart';

import 'package:equatable/equatable.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final IMessageService messageService;
  StreamSubscription? _subscription;
  MessageBloc(this.messageService) : super(MessageState.initial()) {
    on<Subscribed>((event, emit) async {
      await _subscription?.cancel();
      _subscription = messageService
          .messages(event.user)
          .listen((message) => add(_MessageReceived(message)));
    });

    on<_MessageReceived>(
      (event, emit) {
        emit(MessageState.received(event.message));
      },
    );
    on<MessageSent>(
      (event, emit) async {
        await messageService.sent(event.message);
        emit(MessageState.sent(event.message));
      },
    );
  }

 
  @override
  Future<void> close() {
    _subscription?.cancel();
    // messageService.dispose();
    return super.close();
  }
}

part of'message_bloc.dart';
abstract class MessageEvent extends Equatable
{
const MessageEvent();
factory MessageEvent.subscribed(User user)=>Subscribed(user);
factory MessageEvent.messageSent(MessageModel message)=>MessageSent(message);
  @override
  List<Object> get props => [];
}
class Subscribed extends MessageEvent
{
  final User user;
  const Subscribed(this.user);

  @override
  List<Object> get props => [user];
}
class MessageSent extends MessageEvent
{
  final MessageModel message;
  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}
class _MessageReceived extends MessageEvent
{
  final MessageModel message;
  const _MessageReceived(this.message);

  @override
  List<Object> get props => [message];
}


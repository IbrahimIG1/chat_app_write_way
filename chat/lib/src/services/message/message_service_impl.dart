import 'dart:async';

import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/models/message_model.dart';
import 'package:chat/src/services/encryption/encrytion_service_impl.dart';
import 'package:chat/src/services/message/message_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageService implements IMessageService {
  final RethinkDb r;
  final Connection _connection;
  final EncryptionService _encryption;
  final _controller = StreamController<
      MessageModel>.broadcast(); // (broadcast) can be listened to more than once.
  StreamSubscription? _changeFeed;

  MessageService(
    this.r,
    
    this._connection,
    this._encryption,
  );
  @override
  dispose() {
    _controller.close(); // close Stream
  }

  @override
  Stream<MessageModel> messages(User activeUser) {
    _startRecivingMessages(activeUser);
    return _controller.stream;
  }

  _startRecivingMessages(User user) {
    _changeFeed = r
        .table('messages') // go to messages table
        .filter({'to': user.gId}) //  get to (user receive message)
        .changes({'include_initial': true}) //  include_initial
        .run(_connection)
        .asStream() // stream to listen forever
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((element) {
                if (element['new_val'] == null) return; // no message come
                final message =
                    _messageFromFeed(element); // get message when sent
                _controller.sink.add(message);
                _removeDeliverredMessage(message); // remove message from table
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  MessageModel _messageFromFeed(feedDate) {
    var data = feedDate['new_val']; // get message and put in data var
    data['content'] = _encryption.decrypt( data['content']);  // do dncryption before receive message
    return MessageModel.fromJson(
        data); // pass data to fromJson to read the user data
  }

  _removeDeliverredMessage(MessageModel message) {
    r.table('messages').get(message.gId) // message id
        .delete({
      'return_changes': false
    }).run(_connection); // delete message from table (return_changes) to return nothing
  }

  @override
  Future<bool> sent(MessageModel message) async {
    final data = message.toJson();
    data['messageContent'] = _encryption.encrypt(message.messageContent);
    final result = await r
        .table('messages')
        .insert(data)
        .run(_connection); // put message in messages table
    return result['inserted'] == 1; // return 1 in success
  }
}
